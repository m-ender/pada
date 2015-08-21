# coding: utf-8

class Bit
    class ProgramError < Exception; end

    attr_accessor :state

    def initialize(index)
        @index = index

        @state = 0
        @stack = []
        @locked = false
    end

    def process(insn)
        result = :nop
        #p [@index, @state, insn]

        new_state = @state
        case insn
        when :swap_third, :swap_second, :swap_first, :swap_three, :swap_two
            raise "[BUG] Switch-manipulation command reached bits: #{insn} on bit #{@index}"
        when :set_1
            new_state = 1
        when :set_0
            new_state = 0
        when :toggle
            new_state = 1 - @state
        when :push
            @stack << @state
        when :pop
            new_state = @state.pop || rand(2)
        when :write
            result = :write
        when :read
            result = :read
        when :lock
            @locked = !@locked
        when :skip
            result = :skip
        when :jump
            result = :jump
        end

        @state = new_state if !@locked

        result == :nop ? nil : [result, @index]
    end

    def to_s
        @state.to_s + $/ + '_' + $/ + (@stack.reverse * $/)
    end
end