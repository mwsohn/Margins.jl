
function margins(model, catvar, xb = true)

    # original levels
    ncol = mmcolnum(model,catvar)
    vals = unique(model.mf.data[Symbol(catvar)])

    # get modelmatrix and coefs
    X = modelmatrix(model)
    β = coef(model)

    # 
    v = mmcolnum(model, catvar)
    X[:, v] .= 0.0

    # get predicted values
    phat = X * β

    # mean and standard error
    mu = Statistics.mean(phat);
    se = sqrt(var(xb) ./ nobs(model))
    z = mu ./ se
    cv = quantile(Normal(), 0.975)
    pval = 2 .* ccdf(Normal(), z)
    lower = mu .- cv .* se
    upper = mu .+ cv .* se

    if xb == true

        # transformed
        return DataFrame(
            catvar => vals, 
            Margin => mu,
            "Delta SE" => se,
            z => z,
            P => pval,
            lower => lower,
            upper => upper
        )
    end

    # transform back to the response scale

end

function mmcolnum(model,varname)
    if isa(varname, Symbol)
        varname = string(varname)
    end

    loc = findfirst(x -> x == varname, termnames(model)[2])
    return findall(x-> x == loc, model.mm.assign )
end

function deltase(model, mean, stderr)
    if isa(model.model, GeneralizedLinearModel)
        if isa(GLM.Link(model.model.rr), LogitLink)
            deriv = logit_derivative(mean)
        elseif isa(GLM.Link(model.model.rr), IdentityLink)
            deriv = 1
        elseif isa(GLM.Link(model.model.rr), LogLink)
            deriv = 1 / mean
        elseif isa(GLM.Link(model.model.rr), ProbitLink)
            deriv = Distributions.pdf(Normal(), mean)
            # elseif isa(GLM.Link(model.model.rr), InverseLink)
            #     deriv = # need more information
        elseif isa(GLM.Link(model.model.rr), CloglogLink)
            deriv = (1 / (1 - exp(-exp(mean)))) * exp(-exp(mean))
        elseif isa(GLM.Link(model.model.rr), CauchitLink)
            deriv = π / (cos(π * (mean - 0.5))^2)
        end
    end
    # return sqrt(deriv^2 * stderr^2)
    return deriv * stderr
end

function logit_derivative(z)
    s = 1 / (1 + exp(-z))
    return s * (1 - s)
end
