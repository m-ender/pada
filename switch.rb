# coding: utf-8

require_relative 'component'

class Switch < Component

    def initialize(left, right)
        @left = left
        @right = right
    end
    
end