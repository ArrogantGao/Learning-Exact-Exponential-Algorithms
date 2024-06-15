# Branching algorithm for k-SAT problem
# Reference: Exaxt Exponential Algorithms, chapter-2.2

using GenericTensorNetworks, GenericTensorNetworks.TropicalNumbers
using Random, Test, Combinatorics

GenericTensorNetworks._pow(x::TropicalAndOr, y::Int) = y == 1 ? x : zero(x)

function random_k_sat(n, m, k)
    vars = [BoolVar("x_$i") for i in 1:n]
    clauses = []
    for i in 1:m
        clause = []
        while length(clause) < k
            var_id = rand(1:n)
            var = rand(1:2) == 1 ? vars[var_id] : ¬vars[var_id]
            if !(var in clause) && !(¬var in clause)
                push!(clause, var)
            end
        end
        push!(clauses, foldl(∨, clause))
    end
    return foldl(∧, clauses)
end

function cnf2vec(cnf)
    return [clause.vars for clause in cnf.clauses]
end

function solver_gtn(cnf)
    gp = GenericTensorNetwork(Satisfiability(cnf))
    return GenericTensorNetworks.contractx(gp, TropicalAndOr(true); usecuda=false)
end

function ksat_naive(vec_cnf)
    vars = BoolVar.(unique([var.name for clause in vec_cnf for var in clause]))
    for truth_true in [] ∪ combinations(vars)
        truth = [truth_true..., [¬var for var in vars if var ∉ truth_true]...]
        if satisify(vec_cnf, truth)
            return true, truth
        end
    end
    return false, nothing
end

function reduced_clause(caluse, true_vars)
    if any([var in true_vars for var in caluse])
        return nothing
    else
        new_caluse = typeof(caluse)()
        for var in caluse
            if !(¬var in true_vars)
                push!(new_caluse, var)
            end
        end
        return new_caluse
    end
end

function ksat1(vec_cnf, truth=Vector{BoolVar}())
    if isempty(vec_cnf)
        return true, truth
    elseif !isempty(findall(x -> isempty(x), vec_cnf))
        return false, nothing
    end

    for i in 1:length(vec_cnf[1])
        true_vars = [vec_cnf[1][i], [¬vec_cnf[1][j] for j in 1:i - 1]...]
        new_cnf = typeof(vec_cnf)()
        for clause in vec_cnf[2:end]
            new_cluase = reduced_clause(clause, true_vars)
            if isnothing(new_cluase)
                continue
            else
                push!(new_cnf, new_cluase)
            end
        end
        tof, new_truth = ksat1(new_cnf, [truth..., true_vars...])
        if tof == true
            return tof, new_truth
        end
    end
    return false, nothing
end

function satisify(vec_cnf, truth)
    @assert unique([i.name for i in truth]) == [i.name for i in truth]
    if all([any([var in truth for var in clause]) for clause in vec_cnf])
        return true
    else
        return false
    end
end

function main()
    @testset "k-sat by GenericTensorNetworks and branching" begin
        for n in 5:15, m in 10:20, k in 2:5
            cnf = random_k_sat(n, m, k)
            vec_cnf = cnf2vec(cnf)
            tof, truth = ksat1(vec_cnf)
            naive_tof, naive_truth = ksat_naive(vec_cnf)
            @test naive_tof == tof
            if tof == true
                @test satisify(vec_cnf, truth)
            end
            if naive_tof == true
                @test satisify(vec_cnf, naive_truth)
            end
        end
    end
end

main()