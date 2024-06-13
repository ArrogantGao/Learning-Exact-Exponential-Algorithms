# Implenentation of the Traveling Salesman Problem (TSP) using DP
# Refer to 'Exact Expenontial Algorithms', page 5, Fig. 1.1

using SimpleWeightedGraphs, Graphs
using Combinatorics

function roadmap(n::Int64)
    weighted_graph = SimpleWeightedGraph(n)
    for i in 1:n - 1
        for j in i + 1:n
            add_edge!(weighted_graph, i, j, rand(1:10))
        end
    end
    return weighted_graph
end

function tsp(graph::SimpleWeightedGraph{TW, TE}) where{TW, TE}
    n = nv(graph)
    dp = Dict{Tuple{Set{TE}, TE}, TW}()
    for i in 2:n
        s = Set([i])
        d = get_weight(graph, 1, i)
        dp[(s, i)] = d
    end

    for j in 2:n-1
        for s in combinations(2:n, j)
            for i in s
                s_i = Set([k for k in s if k != i])
                for k in s_i
                    d = dp[(s_i, k)] + get_weight(graph, k, i)
                    if !haskey(dp, (s, i)) || d < dp[(s, i)]
                        dp[(Set(s), i)] = d
                    end
                end
            end
        end
    end

    return minimum([dp[(Set(2:n), i)] + get_weight(graph, i, 1) for i in 2:n])
end