# Branching solver for max independent set problem

using Graphs
using Combinatorics
using Test

function _is_independent_set(graph::SimpleGraph{TE}, s::Vector{TE}) where{TE}
    for i in s
        for j in s
            if i != j && has_edge(graph, i, j)
                return false
            end
        end
    end
    return true
end

function mis_naive(graph::SimpleGraph{TE}) where{TE}
    n = nv(graph)
    best = 0
    mis = Vector{TE}()
    for s in powerset(1:n)
        if _is_independent_set(graph, s) && length(s) > best
            best = length(s)
            mis = s
        end
    end
    return best, mis
end

function mis1(g::SimpleGraph{TE}, mis::TE = 0) where{TE}
    n = nv(g)
    if n == 0
        return mis
    end
    dv = degree(g)
    min_dv_i = rand(findall(dv .== minimum(dv)))
    best_mis = mis
    for rem_i in [min_dv_i] ∪ neighbors(g, min_dv_i)
        copy_mis = mis
        copy_mis += 1
        copy_g = deepcopy(g)
        rem_vertices!(copy_g, rem_i ∪ neighbors(copy_g, rem_i))
        new_mis = mis1(copy_g, copy_mis)
        best_mis = max(best_mis, new_mis)
    end
    return best_mis
end

function main()
    @testset "mis_naive vs mis1" begin
        for n in 3:8
            g = random_regular_graph(n, 2)
            global_best, global_mis = mis_naive(g)
            best_mis = mis1(g)
            @test global_best == best_mis
        end
    end
end

main()