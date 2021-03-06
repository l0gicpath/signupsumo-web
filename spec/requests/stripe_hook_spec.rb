require 'rails_helper'

RSpec.describe 'subscriptions/webhook' do
  let!(:subscription) do
    user = Fabricate(:user)
    user.create_subscription.tap do |subscription|
      subscription.customer = { :id => '123' }
      subscription.save
    end
  end
  it 'queues ChecksInfluenceJob' do
    expect(RefreshStripeCustomer).to receive(:perform_later).with(subscription)

    post(stripe_hook_path,
      'type' => 'invoice.payment_succeeded',
      'data' => { 'object' => {'customer' => '123' }}
    )
  end
  it 'queues NotifyPaymentFailure' do
    expect(NotifyPaymentFailure).to receive(:perform_later).with(subscription)

    post(stripe_hook_path,
      'type' => 'invoice.payment_failed',
      'data' => { 'object' => {'customer' => '123' }}
    )
  end
end
