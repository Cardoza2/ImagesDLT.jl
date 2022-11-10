#=
Notes from class:
- You don't really need sub-pixel displacement, it shouldn't move it too much. 

=#

function phimatrix(IW1, IW2)
    g1p = FFTW.fft(IW1)
    g2p = FFTW.fft(IW2)

    return real(FFTW.fftshift(FFTW.ifft(g1p.*conj(g2p))))
end

function getdisplacement(phi)
    N, M = size(phi)
    _, idx = findmax(phi)
    xstar = idx[2] 
    ystar = idx[1]
    x0 = ceil(Int64, M/2)
    y0 = ceil(Int64, N/2)

    return -(xstar-x0), -(ystar-y0) #-(xstar-x0-1), (ystar-y0-1) The negative ones push the velocities to zero when the same image is input. 
end

export track

function track(mats, u0, v0, windowsize::Int; plotflag::Bool=false, invert::Bool=true)

    if mod(windowsize, 2)!=0
        @warn("Window size should be even, adjusting window size")
        windowsize -= 1
    end

    ws2 = Int(windowsize/2)

    nx, ny, n = size(mats)
    u = Array{Int, 1}(undef, n)
    v = Array{Int, 1}(undef, n)
    # phi = Array{Float64, 2}(undef, windowsize+1, windowsize+1)
    

    #Set x0 in x
    u[1] = u0
    v[1] = v0



    for i = 2:n
        #Determine window
        xidx1 = u[i-1] - ws2
        xidx2 = u[i-1] + ws2
        yidx1 = v[i-1] - ws2
        yidx2 = v[i-1] + ws2

        if xidx1<1
            @warn("Edge of window attempted to leave image, setting window edge at image edge.")
            xidx1=1
        end
        if xidx2>nx
            @warn("Edge of window attempted to leave image, setting window edge at image edge.")
            xidx2=nx
        end
        if yidx1<1
            @warn("Edge of window attempted to leave image, setting window edge at image edge.")
            yidx1=1
        end
        if yidx2>ny
            @warn("Edge of window attempted to leave image, setting window edge at image edge.")
            yidx2=ny
        end

        if invert
            IW1 = 1.0 .- mats[yidx1:yidx2, xidx1:xidx2, i-1]
            IW2 = 1.0 .- mats[yidx1:yidx2, xidx1:xidx2, i]
        else
            IW1 = mats[yidx1:yidx2, xidx1:xidx2, i-1]
            IW2 = mats[yidx1:yidx2, xidx1:xidx2, i]
        end

        # iplt = plot(Gray.(IW1))  
        # display(iplt)
        
        # iplt = plot(Gray.(IW2))
        # display(iplt)

        

        #Search image
        phi = phimatrix(IW1, IW2)

        # hplt = heatmap(phi)
        # display(hplt)

        #Save new position. 
        dx, dy = getdisplacement(phi)
        # @show dx, dy
        u[i] = u[i-1] + dx
        v[i] = v[i-1] + dy

        if plotflag
            xwin = [xidx1, xidx2, xidx2, xidx1, xidx1]
            ywin = [yidx1, yidx1, yidx2, yidx2, yidx1]

            plt = plot(Gray.(mats[:,:,i]), leg=false)
            plot!(xwin, ywin, linecolor=:red)
            scatter!([u[i-1]], [v[i-1]], markershape=:x, markercolor=:red)
            display(plt)
        end
    end
    return u, v
end

export xyz_position

function xyz_position(ul, vl, ur, vr, L, R)
    F = [L[1]-(L[9]*ul) L[2]-(L[10]*ul) L[3]-(L[11]*ul)
         L[5]-(L[9]*vl) L[6]-(L[10]*vl) L[7]-(L[11]*vl)
         R[1]-(R[9]*ur) R[2]-(R[10]*ur) R[3]-(R[11]*ur)
         R[5]-(R[9]*vr) R[6]-(R[10]*vr) R[7]-(R[11]*vr)]

    G = [ul - L[4]
         vl - L[8]
         ur - R[4]
         vr - R[8]]

    return PenroseMooreInverse(F, G)
end