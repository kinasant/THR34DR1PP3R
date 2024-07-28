from subprocess import check_output, DEVNULL, CalledProcessError
import itertools
from re import findall


def sort_by_norm(M):
    # idk why .norm() is really slow
    M2 = [(sum([y ^ 2 for y in x]), x) for x in M]
    M2.sort()
    return matrix([y for x, y in M2])


def flatter(M):
    # compile https://github.com/keeganryan/flatter and put it in $PATH
    z = "[[" + "]\n[".join(" ".join(map(str, row)) for row in M) + "]]"
    ret = check_output(["flatter"], input=z.encode())
    return matrix(M.nrows(), M.ncols(), map(int, findall(b"-?\\d+", ret)))



def LLL(M):
    return M.LLL()



def small_roots(f, bounds, m=1, d=None, reduction=LLL):
    # modified from https://github.com/defund/coppersmith/blob/master/coppersmith.sage
    if not d:
        d = f.degree()

    R = f.base_ring()
    N = R.cardinality()

    f /= f.coefficients().pop(0)
    f = f.change_ring(ZZ)

    G = Sequence([], f.parent())
    for i in range(m + 1):
        base = N ^ (m - i) * f ^ i
        for shifts in itertools.product(range(d), repeat=f.nvariables()):
            g = base * prod(map(power, f.variables(), shifts))
            G.append(g)

    B, monomials = G.coefficient_matrix()
    monomials = vector(monomials)

    factors = [monomial(*bounds) for monomial in monomials]
    for i, factor in enumerate(factors):
        B.rescale_col(i, factor)

    B = reduction(B.dense_matrix())

    B = B.change_ring(QQ)
    for i, factor in enumerate(factors):
        B.rescale_col(i, 1 / factor)

    H = Sequence([], f.parent().change_ring(QQ))
    for h in filter(None, B * monomials):
        H.append(h)
        I = H.ideal()
        if I.dimension() == -1:
            H.pop()
        elif I.dimension() == 0:
            roots = []
            for root in I.variety(ring=QQ, algorithm="msolve", proof=False):
                root = tuple(R(root[var]) for var in f.variables())
                roots.append(root)
            return roots

    return []
