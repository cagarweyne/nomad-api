const expect = require("chai").expect;
const calculateOrderAmount = require("../helpers/calculateOrder");

describe("Calculate function", function () {
  describe("return value in cents", function () {
    it("converts the us amount to cents", function () {
      const cartItems = [
        { price: 28.99, quantity: 1 },
        { price: 58.99, quantity: 1 },
      ];
      const amountInCents = calculateOrderAmount(cartItems);
      expect(amountInCents).to.equal(8798);
    });
  });
});
