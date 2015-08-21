# coding: utf-8

require_relative 'bit'
require_relative 'switch'

class Pada

    class ProgramError < Exception; end

    OPERATORS = {
        # Switch manipulation
        "O" => :swap_third,
        "o" => :swap_second,
        "." => :swap_first,
        "Q" => :swap_three,
        "q" => :swap_two,

        # Bit manipulation
        "1" => :set_1,
        "0" => :set_0,
        "~" => :toggle,
        "v" => :push,
        "^" => :pop,

        # I/O
        "w" => :write,
        "r" => :read,

        # Control flow
        "#" => :lock,
        "?" => :skip,
        "*" => :jump,
    }

    def self.run(src, char)
        if OPERATORS.has_key? char
            raise "[ERROR] Invalid debug character #{char}. Clashes with built-in."
        else
            OPERATORS[char] = :debug
        end
        new(src).run
    end

    def initialize(src)
        @insns = parse(src)
        @bits = Array.new(8) { |i| Bit.new i }
        # Repeat (by reference) for easier cyclic access
        @bits *= 2   

        @tree = Switch.new(
                    Switch.new(
                        Switch.new(
                            @bits[0], 
                            @bits[1]
                        ),
                        Switch.new(
                            @bits[2], 
                            @bits[3]
                        )
                    ),
                    Switch.new(
                        Switch.new(
                            @bits[4], 
                            @bits[5]
                        ),
                        Switch.new(
                            @bits[6], 
                            @bits[7]
                        )
                    )
                )
    end

    def run
        pc = 0
        while pc < @insns.size
            insn = @insns[pc]

            if insn == :debug
                puts
                puts @tree
            else
                command, bit = *@tree.process(insn)

                if bit
                    byte = @bits[bit, 8].map(&:state).join.to_i(2)
                end

                case command
                when :write
                    STDOUT << byte.chr
                when :read
                    byte = STDIN.read(1).ord
                    8.times { |i| 
                        @bits[bit + i].state = (byte>>(7-i))&1
                    }
                when :skip
                    pc += @bits[bit].state
                when :jump
                    pc = [pc + jump, 0].max
                end
            end

            pc += 1
        end
    end

    private

    def parse(src)
        insns = []

        src.each_char do |c|
            if OPERATORS[c]
                insns << OPERATORS[c]
            end
        end

        insns
    end

end

debug_flag = ARGV[0][/^-d=(.)/]
if debug_flag
    char = debug_flag.split('=')[1]
    ARGV.shift
end

Pada.run(ARGF.read, char)