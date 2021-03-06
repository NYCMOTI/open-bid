class BidStatusPresenterFactory
  attr_reader :auction, :user, :bid_error

  def initialize(auction:, user:, bid_error: nil)
    @auction = auction
    @user = user
    @bid_error = bid_error
  end

  def create
    if auction.unpublished?
      BidStatusPresenter::Unpublished::Guest
    elsif future?
      future_message
    elsif over? && user_is_winning_bidder?
      over_winning_bidder_message
    elsif over?
      over_message
    else
      available_message
    end.new(auction: auction, user: user, bid_error: bid_error)
  end

  private

  def future_message
    if admin?
      AdminAuctionStatusPresenter::Future
    elsif guest?
      BidStatusPresenter::Future::Guest
    else
      BidStatusPresenter::Future::Vendor
    end
  end

  def over_winning_bidder_message
    if auction.missed_delivery?
      BidStatusPresenter::Over::Vendor::Winner::MissedDelivery
    elsif !auction.pending_delivery?
      Object.const_get("BidStatusPresenter::Over::Vendor::Winner::#{auction.delivery_status.camelize}")
    elsif auction.payment_confirmed?
      BidStatusPresenter::Over::Vendor::Winner::PaymentConfirmed
    else
      BidStatusPresenter::Over::Vendor::Winner::WorkNotStarted
    end
  end

  def over_message
    if user_is_bidder?
      BidStatusPresenter::Over::Vendor::Bidder
    else
      BidStatusPresenter::Over::NotBidder
    end
  end

  def available_message
    if admin?
      AdminAuctionStatusPresenter::Available
    elsif guest?
      BidStatusPresenter::Available::Guest
    elsif ineligible?
      ineligible_presenter
    elsif bid_error.present?
      BidStatusPresenter::Available::Vendor::BidError
    elsif rules.user_can_bid?(user)
      user_can_bid_message
    elsif auction.type == 'reverse'
      BidStatusPresenter::Available::Vendor::WinningBidder
    elsif auction.type == 'open_call'
      BidStatusPresenter::Available::Vendor::OpenCallAuctionBidder
    else # sealed bid, user is bidder
      BidStatusPresenter::Available::Vendor::SealedAuctionBidder
    end
  end

  def user_can_bid_message
    if user_bids.any?
      if auction.type == 'open_call'
        BidStatusPresenter::Available::Vendor::OpenCallAuctionBidder
      else
        BidStatusPresenter::Available::Vendor::ReverseAuctionOutbid
      end
    else
      BidStatusPresenter::Available::Vendor::Eligible
    end
  end

  def ineligible_presenter
    if user.fms_status != 'fms_accepted'
      BidStatusPresenter::Available::Vendor::NotFmsVerified
    else
      BidStatusPresenter::Available::Vendor::NotSmallBusiness
    end
  end

  def admin?
    user.decorate.admin?
  end

  def guest?
    user.is_a?(Guest)
  end

  def ineligible?
    !EligibilityFactory.new(auction).create.eligible?(user)
  end

  def work_in_progress?
    auction.work_in_progress?
  end

  def over?
    bidding_status.over?
  end

  def available?
    bidding_status.available?
  end

  def future?
    bidding_status.future?
  end

  def bidding_status
    BiddingStatus.new(auction)
  end

  def user_is_winning_bidder?
    user_bids.any? && lowest_user_bid == auction.lowest_bid
  end

  def user_is_bidder?
    user_bids.any?
  end

  def lowest_user_bid
    user_bids.order(amount: :asc).first
  end

  def user_bids
    auction.bids.where(bidder: user)
  end

  def rules
    @_rules ||= RulesFactory.new(auction).create
  end
end
