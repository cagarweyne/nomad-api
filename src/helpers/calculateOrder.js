function calculateOrderAmount(cartItems) {
  return cartItems.reduce((total, product) => {
    return total + product.price * product.quantity;
  }, 0) * 100;
}
module.exports = calculateOrderAmount;