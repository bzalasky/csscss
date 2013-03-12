module Csscss
  class Declaration < Struct.new(:property, :value, :parents)
    def self.from_csspool(dec)
      new(dec.property.to_s.downcase, dec.expressions.join(" ").downcase)
    end

    def self.from_parser(property, value, clean = true)
      value = value.to_s
      value = value.downcase if clean
      new(property.to_s, value.strip)
    end

    def derivative?
      !parents.nil?
    end

    def without_parents
      if derivative?
        dup.tap do |duped|
          duped.parents = nil
        end
      else
        self
      end
    end

    def ==(other)
      if derivative?
        without_parents == other
      else
        super(other.respond_to?(:without_parents) ? other.without_parents : other)
      end
    end

    def hash
      derivative? ? without_parents.hash : super
    end

    def eql?(other)
      hash == other.hash
    end

    def <=>(other)
      property <=> other.property
    end

    def >(other)
      other.derivative? && other.parents.include?(self)
    end

    def <(other)
      other > self
    end

    def to_s
      "#{property}: #{value}"
    end

    def inspect
      if parents
        "<#{self.class} #{to_s} (parents: #{parents})>"
      else
        "<#{self.class} #{to_s}>"
      end
    end
  end

  class Selector < Struct.new(:selectors)
    def <=>(other)
      selectors <=> other.selectors
    end

    def to_s
      selectors.join(", ")
    end

    def inspect
      "<#{self.class} #{selectors}>"
    end
  end
end
