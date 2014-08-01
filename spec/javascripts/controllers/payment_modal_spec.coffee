#= require spec_helper

describe 'PaymentModal', ->
  beforeEach ->
    @controller('PaymentModal', { $scope: @scope })

  describe '#processPayment', ->
    it 'does something', ->
      expect(true).toEq(true)
