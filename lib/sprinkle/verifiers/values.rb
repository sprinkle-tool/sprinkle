module Sprinkle
  module Verifiers
    # = Values Verifier
    #
    # Contains a verifier to compare an expression with a value.
    # 
    # == Example Usage
    #
    #   verify { check_equality "passenger -v | head -1 | cut -f4 -d' '", '3.0.5' }
    #
    module Values
      Sprinkle::Verify.register(Sprinkle::Verifiers::Values)

      # Checks to make sure that the result of expression on the remote server is equal to value.
      def check_equality(expr, value)
        @commands << "test `#{expr}` = '#{value}'"
      end

    end
  end
end
