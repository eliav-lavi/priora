RSpec.describe Priora do
  let(:low_like_count_sponsored) { post_class.new(author: 'Jay C.', like_count: 10, is_sponsored: true) }
  let(:high_like_count_unsponsored) { post_class.new(author: 'Aaron R.', like_count: 90, is_sponsored: false) }
  let(:high_like_count_sponsored) { post_class.new(author: 'Don Y.', like_count: 90, is_sponsored: true) }

  let(:post_class) do
    Class.new do
      attr_reader :author, :like_count, :is_sponsored

      def initialize(author:, like_count:, is_sponsored:)
        @author = author
        @like_count = like_count
        @is_sponsored = is_sponsored
      end
    end
  end

  describe '.prioritize' do
    context 'domain class does not declare prioritize_by' do
      let(:unprioritized_array) { [high_like_count_unsponsored, low_like_count_sponsored, high_like_count_sponsored] }

      context 'and priorities are supplied as a parameter' do
        it 'prioritizes objects according to supplied parameter' do
          expect(Priora.prioritize(unprioritized_array, by: [:like_count, :is_sponsored]))
              .to eq [high_like_count_sponsored, high_like_count_unsponsored, low_like_count_sponsored]
        end
      end

      context 'and priorities are not supplied as a parameter' do
        it 'raises UnsuppliedPrioritiesError' do
          expect { Priora.prioritize(unprioritized_array) }.to raise_error(Priora::UnsuppliedPrioritiesError)
        end
      end
    end

    context 'domain class does declare prioritize_by' do
      let(:post_class) do
        Class.new do
          include Priora
          prioritize_by :like_count, :is_sponsored

          attr_reader :author, :like_count, :is_sponsored

          def initialize(author:, like_count:, is_sponsored:)
            @author = author
            @like_count = like_count
            @is_sponsored = is_sponsored
          end
        end
      end

      let(:unprioritized_array) { [high_like_count_unsponsored, low_like_count_sponsored, high_like_count_sponsored] }

      context 'and priorities are not supplied as a parameter' do
        it 'prioritizes objects according to class declaration' do
          expect(Priora.prioritize(unprioritized_array))
              .to eq [high_like_count_sponsored, high_like_count_unsponsored, low_like_count_sponsored]
        end
      end

      context 'and priorities are supplied as a parameter' do
        it 'prioritizes objects according to supplied parameter' do
          expect(Priora.prioritize(unprioritized_array, by: [:is_sponsored, :like_count])).
              to eq [high_like_count_sponsored, low_like_count_sponsored, high_like_count_unsponsored]
        end
      end
    end

    context 'directional priorities' do
      let(:unprioritized_array) { [high_like_count_unsponsored, low_like_count_sponsored, high_like_count_sponsored] }

      it 'prioritize lower values first for specific attributes by using :asc explicitly' do
        expect(Priora.prioritize(unprioritized_array, by: [[like_count: :asc], :is_sponsored]))
            .to eq [low_like_count_sponsored, high_like_count_sponsored, high_like_count_unsponsored]
      end

      it 'accepts a hash as well' do
        expect(Priora.prioritize(unprioritized_array, by: [{ like_count: :asc }, :is_sponsored]))
            .to eq [low_like_count_sponsored, high_like_count_sponsored, high_like_count_unsponsored]
      end

      it 'raises InvalidPrioritySyntaxError when multiple attributes are declared in the same array' do
        expect { Priora.prioritize(unprioritized_array, by: [[like_count: :asc, is_sponsored: :asc]]) }
            .to raise_error(Priora::InvalidPrioritySyntaxError)
      end

      it 'raises InvalidPrioritySyntaxError when multiple attributes are declared in the same hash' do
        expect { Priora.prioritize(unprioritized_array, by: [{ like_count: :asc, is_sponsored: :asc }]) }
            .to raise_error(Priora::InvalidPrioritySyntaxError)
      end

      it 'does allow for several directional priorities declared separately' do
        expect(Priora.prioritize(unprioritized_array, by: [[like_count: :asc], [is_sponsored: :asc]]))
            .to eq [low_like_count_sponsored, high_like_count_unsponsored, high_like_count_sponsored]
      end
    end

    context 'supplying custom class lambdas' do
      before do
        Priora.configuration.add_conversion_lambda(String, -> (value) { value.length })
      end

      after do
        Priora.configuration.remove_conversion_lambda(String)
      end

      let(:long_author_name) { post_class.new(author: 'Sir S. Longname', like_count: anything, is_sponsored: anything)}
      let(:short_author_name) { post_class.new(author: 'R. Short', like_count: anything, is_sponsored: anything)}

      let(:unprioritized_array) { [short_author_name, long_author_name] }

      it 'prioritizes objects by length of author string, according to supplied lambda' do
        expect(Priora.prioritize(unprioritized_array, by: [:author])).to eq [long_author_name, short_author_name]
      end
    end
  end
end
