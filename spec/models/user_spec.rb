RSpec.describe User do
  before(:each) do
    build_user
  end

  describe '#initialize' do
    it 'creates an instance of a user' do
      expect(@user).to be_a User
    end
  end

  describe '#toggle_subscription!' do
    context 'subscribed' do
      it 'unsubscribes you' do
        @user.unsubscribed = false
        @user.toggle_subscription!
        expect(@user.unsubscribed).to be true
      end
    end

    context 'not subscribed' do
      it 'subscribes you' do
        @user.unsubscribed = true
        @user.toggle_subscription!
        expect(@user.unsubscribed).to be false
      end
    end
  end

  describe '#unsubscribe!' do
    it 'unsubscribes you' do
      @user.unsubscribe!
      expect(@user.unsubscribed).to be true
    end
  end

  describe '#email_reminder' do
    it 'sends an email reminder' do
      @user.save
      @user.email_reminder(44, 'monday')
    end
  end

  def build_user
    @user = User.new(
      name: 'The Donald',
      email: 'potus@whitehouse.gov'
    )
  end
end
