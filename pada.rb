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

    def self.run(src)
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
        p @insns
        pc = 0
        while pc < @insns.size
            insn, arg = *@insns[pc]

            case insn
            when :push
                push(arg)
            when :dup
                push(@stack[-1])
            when :swap
                y, x = pop, pop
                push(y)
                push(x)
            when :rotate
                z, y, x = pop, pop, pop
                push(z)
                push(x)
                push(y)
            when :pop
                pop

            when :+
                y, x = pop, pop
                push(x + y)
            when :-
                y, x = pop, pop
                push(x - y)
            when :*
                y, x = pop, pop
                push(x * y)
            when :/
                y, x = pop, pop
                push(x / y)
            when :%
                y, x = pop, pop
                push(x % y)

            when :num_out
                print pop
            when :char_out
                print pop.chr
            when :char_in
                push($stdin.getc.ord)
            when :num_in
                push($stdin.gets.to_i)

            when :label
                # ラベルの位置は既に調べてあるので、何もしない
            when :jump
                if pop != 0
                    pc = @labels[arg]
                    raise ProgramError, "ジャンプ先(#{arg.inspect})が見つかりません" if pc.nil?
                end

            else
                raise "[BUG] 知らない命令です(#{insn})"
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

    def select(ops, n)
        op = ops[n % ops.size]
        [op]
    end

    def find_labels(insns)
        labels = {}
        insns.each_with_index do |(insn, arg), i|
            if insn == :label
                raise ProgramError, "ラベル#{arg}が重複しています" if labels[arg]
                labels[arg] = i
            end
        end
        labels
    end

    def push(item)
        unless item.is_a?(Integer)
            raise ProgramError, "整数以外(#{item})をプッシュしようとしました" 
        end
        @stack.push(item)
    end

    def pop
        item = @stack.pop
        raise ProgramError, "空のスタックをポップしようとしました" if item.nil?
        item
    end

end

Pada.run(ARGF.read)