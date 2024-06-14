# Implenentation of the Traveling Salesman Problem (TSP) using DP
# Refer to 'Exact Expenontial Algorithms', page 5, Fig. 1.1

using SimpleWeightedGraphs, Graphs
using Combinatorics
using Test

function roadmap(n::Int64)
    weighted_graph = SimpleWeightedGraph(n)
    for i in 1:n - 1
        for j in i + 1:n
            add_edge!(weighted_graph, i, j, rand(1:10))
        end
    end
    return weighted_graph
end

function tsp_dp(graph::SimpleWeightedGraph{TE, TW}) where{TW, TE}
    n = nv(graph)
    dp = Dict{Tuple{Set{TE}, TE}, TW}()
    for i in 2:n
        s = Set([i])
        d = get_weight(graph, 1, i)
        dp[(s, i)] = d
    end

    for j in 2:n-1
        for s in combinations(2:n, j)
            ss = Set(s)
            for i in s
                s_i = Set([k for k in s if k != i])
                for k in s_i
                    d = dp[(s_i, k)] + get_weight(graph, k, i)
                    if !haskey(dp, (ss, i)) || d < dp[(ss, i)]
                        dp[(ss, i)] = d
                    end
                end
            end
        end
    end

    return minimum([dp[(Set(2:n), i)] + get_weight(graph, i, 1) for i in 2:n])
end

function tsp_navive(graph::SimpleWeightedGraph{TE, TW}) where{TW, TE}
    n = nv(graph)
    best = Inf
    for s in permutations(1:n)
        d = get_weight(graph, s[end], s[1]) + sum([get_weight(graph, s[i], s[i + 1]) for i in 1:n - 1])
        best = min(d, best)
    end
    return best
end

function main()
    @testset "tsp_dp vs naive" begin
        for n in 3:8
            wg = roadmap(n)
            global_min = tsp_navive(wg)
            dp_min = tsp_dp(wg)
            @test global_min == dp_min
        end
    end
end

main()