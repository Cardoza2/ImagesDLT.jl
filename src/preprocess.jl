

export convertimage

function convertimage(image) 
    if !(eltype(image) <: Images.Gray) #if not grayscale, convert to grayscale
        image = Images.Gray.(image)
    end

    grays = Images.channelview(image) #Convert the image to color types
    return Images.float.(grays) #Convert the image to numbers
end

abstract type Preprocess end

abstract type ImageProcess <: Preprocess end

abstract type MatrixProcess <: Preprocess end

### Put new preprocessing structs here and define methods on the structs. 

export Contrast

struct Contrast <: MatrixProcess
    a::Float64
    b::Float64 #TODO: I'm not sure that I need this second value, because I'm ranging from 0 to 1. At the same time, it doesn't look like it hurts it, but I'll default to 1. 
end

function Contrast(a)
    return Contrast(a, 1)
end

function (method::Contrast)(mat)
    Gmax = maximum(mat)^method.a
    Gmin = minimum(mat)^method.a

    n, m = size(mat)

    for i = 1:n
        for j = 1:m
            mat[i,j] = (2^method.b - 1)*(mat[i,j]^method.a - Gmin)/(Gmax-Gmin)
        end
    end
end



export preprocess

function preprocess(images, kwargs...)
    ni = length(images)
    np = length(kwargs)

    isy, isx = size(images[1])
    for i = 2:ni
        isyi, isxi = size(images[i])
        if (isyi>isy)&&(isxi>isx)
            error("Haven't implemented trimming function, make sure the functions are the same size.")
        elseif (isy, isx)!=(isyi, isxi)
            error("Note that all image sizes must be the same.")
        end
    end

    mat = Array{Float64, 3}(undef, isy, isx, ni)

    ### sort kwargs into image processes, and matrix processes. 
    imageprocesses = Array{ImageProcess, 1}(undef, 0)
    matrixprocesses = Array{MatrixProcess, 1}(undef, 0)
    for i = 1:np
        if isa(kwargs[i],ImageProcess)
            push!(imageprocesses, kwargs[i])
        else
            push!(matrixprocesses, kwargs[i])
        end
    end 
    npi = length(imageprocesses)
    npm = length(matrixprocesses)

    for i = 1:ni
        image = images[i]
        for pi = 1:npi
            imageprocesses[pi](image)
        end

        mat[:,:,i] = convertimage(image)

        for pm = 1:npm
            matrixprocesses[pm](view(mat, :, :, i))
        end
    end

    return mat
end

export filterimage!

abstract type Filter end #Todo: I may want to make this a sub-type of matrixprocess. 

struct Average <: Filter
end

filterimage!(mats) = filterimage!(mats, Average())

function filterimage!(mats::Array{Float64, 3}, filtertype::Average)
    m, n, ni = size(mats)

    avg = zeros(m, n)

    for i = 1:ni
        for j = 1:m
            for k = 1:n
                avg[j,k] += mats[j,k,i]
            end
        end
    end

    avg .= avg./ni

    # display(Gray.(avg))

    for i = 1:ni
        @. mats[:,:,i] = 1.0 - (avg - mats[:,:,i])
    end

    mats[findall(x->x>1, mats)] .= 1.0 #Cap at 1.0
    mats[findall(x->x<0, mats)] .= 0.0


    return mats 
end

export FGsolve

function PenroseMooreInverse(F, g)
    Ft = transpose(F)
    return inv(Ft*F)*Ft*g
end

function FGsolve(xvec, yvec, zvec, uvec, vvec)
    if length(xvec)!=length(yvec)!=length(zvec)!=length(uvec)!=length(vvec)
        error("X, Y, U, and V vectors must be same length.")
    end
    N = length(xvec)
    Fmat = zeros(2*N, 11)
    Gvec = zeros(2*N)
    odds = 1:2:2*N
    evens = 2:2:2*N

    for i = 1:N
        j = evens[i]
        k = odds[i]
        Fmat[k, 1] = xvec[i]
        Fmat[k, 2] = yvec[i]
        Fmat[k, 3] = zvec[i]
        Fmat[k, 4] = 1.0

        Fmat[j, 5] = xvec[i]
        Fmat[j, 6] = yvec[i]
        Fmat[j, 7] = zvec[i]
        Fmat[j, 8] = 1.0

        Fmat[k, 9] = -uvec[i]*xvec[i]
        Fmat[k, 10] = -uvec[i]*yvec[i]
        Fmat[k, 11] = -uvec[i]*zvec[i]

        Fmat[j, 9] = -vvec[i]*xvec[i]
        Fmat[j, 10] = -vvec[i]*yvec[i]
        Fmat[j, 11] = -vvec[i]*zvec[i]

        Gvec[k] = uvec[i]
        Gvec[j] = vvec[i]
    end
    # Ft = transpose(Fmat)
    # return inv(Ft*Fmat)*Ft*Gvec
    return PenroseMooreInverse(Fmat, Gvec)
end


function uv_position(M, x, y, z) #Not used
    topu = M[1]*x + M[2]*y + M[3]*z + M[4]
    topv = M[5]*x + M[6]*y + M[7]*z + M[8]
    bot = M[9]*x + M[10]*y + M[11]*z + 1
    u = topu/bot
    v = topv/bot
    return u, v
end