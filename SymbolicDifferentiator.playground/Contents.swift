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

print("\nevaluation and sugar test:")
let f: Expr = 20 * (x ^ 2)
let g: Expr = f′

print("\(f.toString()) \(f(3))")
print("\(g.toString()) \(g(3))")

print("\nfunctions test:")
let h: Expr = (ln(.const(e)) * log(3, x) * cos(x) - (sin(.const(pi) * x) + sin(.const(2 * pi))))
    .flattened().simplified()
let j: Expr = h′

print("")
print(h.toString())
print(h.prettyTree())
print("")
print(j.toString())
print(j.prettyTree())

print(h(3))
print(j(3))

print("")
print("new sum simp test:")
let sumTest: Expr = (3 * (x-1)) + (3 * (x-1)) + 5 + 7
print(sumTest.prettyTree())
print()
let sumTestSimp = sumTest.flattened().simplified()
print(sumTestSimp.prettyTree())
print(sumTestSimp.toString())

print("")
print("difference printing:")
let negateTest: Expr = (1 - (3 * x)).flattened().simplified()
print(negateTest.prettyTree())
print(negateTest.toString())
