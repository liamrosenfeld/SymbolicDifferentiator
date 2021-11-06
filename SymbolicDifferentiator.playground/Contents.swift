let x: Expr = .variable

print("orig:")
let expr: Expr = (3.0 * x) * (3.0 * (x ^ 2.0)) + (3 * x) / ((1 - 2 - 3) * (1 * 2 * x))
print(expr.toString())

print("\norig tree:")
print(expr.prettyTree())

print("\nflattened tree:")
let flattened = expr.flattened()
print(flattened.prettyTree())

print("\nsimplified tree:")
let simplified = flattened.simplified()
print(simplified.prettyTree())

print("\nsimplified expressinon:")
print(simplified.toString())

print("\nderiv:")
let deriv = simplified.deriv()
print(deriv.toString())

print("\nderiv tree:")
print(deriv.prettyTree())

print("\nflat deriv tree:")
let flatDeriv = deriv.flattened()
print(flatDeriv.prettyTree())

print("\nsimp deriv tree:")
let simpDeriv = flatDeriv.simplified()
print(simpDeriv.prettyTree())

print("\nsimp deriv expr:")
print(simpDeriv.toString())
