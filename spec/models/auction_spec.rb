require 'rails_helper'

describe Auction do
  describe "Associations" do
    it { should belong_to(:user) }
  end

  describe 'Validations' do
    context 'on create' do
      it { should validate_presence_of(:billable_to) }
      it { should validate_presence_of(:delivery_due_at) }
      it { should validate_presence_of(:ended_at) }
      it { should validate_presence_of(:purchase_card) }
      it { should validate_presence_of(:start_price) }
      it { should validate_presence_of(:started_at) }
      it { should validate_presence_of(:title) }
      it { should validate_presence_of(:user) }
      it do
        should_not allow_values(
          ENV['C2_HOST'], 'http://www.example.com'
        ).for(:c2_proposal_url)
      end
      it { should allow_value("#{ENV['C2_HOST']}/proposals/123").for(:c2_proposal_url) }
      it { should allow_value('').for(:c2_proposal_url) }

      describe "starting price validations" do
        context "creator is admin" do
          it "does not allow auction to have start price above 3500" do
            user = create(:admin_user)
            auction = build(:auction, user: user, start_price: 5000)

            expect(auction).not_to be_valid
          end
        end

        context "creator is contracting officer" do
          it "allows auctions to have a start price over 3500" do
            user = create(:contracting_officer)
            auction = build(:auction, user: user, start_price: 5000)

            expect(auction).to be_valid
          end
        end
      end
    end

    context 'when set to archived' do
      it 'does not run date validations' do
        start_date = DefaultDateTime.new(2.days.from_now).convert
        end_date = DefaultDateTime.new(Time.current).convert
        auction = create(:auction, :unpublished, started_at: start_date, ended_at: end_date)

        auction.published = :archived

        expect(auction).to be_valid
      end
    end

    context 'when set to published' do
      it 'validates presence of summary' do
        auction = create(:auction, published: :unpublished)

        auction.published = :published
        auction.summary = nil

        expect(auction).to be_invalid
      end

      it 'validates presence of description' do
        auction = create(:auction, published: :unpublished)

        auction.published = :published
        auction.description = nil

        expect(auction).to be_invalid
      end

      context 'auction is for default purchase card and is not budget approved' do
        it 'validates c2_status when published' do
          auction = create(:auction, :unpublished, purchase_card: :default)

          auction.published = :published

          expect(auction).to be_invalid
          expect(auction.errors.messages).to eq(c2_status: ["is not budget approved"])
        end
      end

      context 'auction is for default purchase card and is budget approved' do
        it 'validates c2_status when published' do
          auction = create(:auction, :unpublished, purchase_card: :other)

          auction.published = :published

          expect(auction).to be_valid
        end
      end

      context 'start date is after end date' do
        it 'is invalid' do
          start_date = DefaultDateTime.new(2.days.from_now).convert
          end_date = DefaultDateTime.new(Time.current).convert
          auction = create(:auction, :unpublished, started_at: start_date, ended_at: end_date)

          auction.published = :published

          expect(auction).to be_invalid
          expect(auction.errors.messages[:base]).to eq(
            ["You must specify an auction end date/time that comes after the auction start date/time."]
          )
        end
      end

      context 'start date is before today' do
        it 'is invalid' do
          start_date = DefaultDateTime.new(2.days.ago).convert
          auction = create(:auction, :unpublished, started_at: start_date)

          auction.published = :published

          expect(auction).to be_invalid
          expect(auction.errors.messages[:base]).to eq(
            ["You must specify an auction start date/time that is after today."]
          )
        end
      end
    end
  end

  describe '#sorted_skill_names' do
    it 'returns alpha ordered skills' do
      c_skill = create(:skill, name: 'c')
      a_skill = create(:skill, name: 'a')
      b_skill = create(:skill, name: 'b')
      auction = create(:auction)
      auction.skills << [c_skill, a_skill, b_skill]

      expect(auction.sorted_skill_names).to eq(%w(a b c))
    end
  end

  describe "#lowest_bid" do
    context "multiple bids" do
      it "returns bid with lowest amount" do
        auction = FactoryGirl.create(:auction)
        low_bid = FactoryGirl.create(:bid, auction: auction, amount: 1)
        _high = FactoryGirl.create(:bid, auction: auction, amount: 10000)

        expect(auction.lowest_bid).to eq(low_bid)
      end
    end

    context "no bids" do
      it "returns nil" do
        auction = FactoryGirl.create(:auction)

        expect(auction.lowest_bid).to be_nil
      end
    end

    context "multiple bids with same amount" do
      it "returns first created bid" do
        auction = FactoryGirl.create(:auction)
        _second_bid = FactoryGirl.create(:bid, auction: auction, created_at: Time.current, amount: 1)
        first_bid = FactoryGirl.create(:bid, auction: auction, created_at: 1.hour.ago, amount: 1)

        expect(auction.lowest_bid).to eq(first_bid)
      end
    end
  end

  describe '#token' do
    it 'should automatically be generated when the auction is saved' do
      auction = build(:auction)

      expect(auction.token).to be_nil
      expect { auction.save! }.to change { auction.token }
    end
  end
end
