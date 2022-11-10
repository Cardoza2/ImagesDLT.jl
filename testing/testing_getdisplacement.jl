


using ImagesDLT, Images, Plots

dlt = ImagesDLT

currentdir = @__DIR__

cd(currentdir)

filepath = "../data/data_Camera1/"

files = readdir(filepath)
removevec = Int[]

for i = 1:length(files)
    if occursin(".cih", files[i])
        push!(removevec, i)
    end
end

for i = length(removevec):-1:1
    popat!(files, removevec[i])
end

files = filepath.*files

images = [load(img) for img in files[1:5]]

mat = preprocess(images, Contrast(1.5))

# @show minimum(mat)

filterimage!(mat)

nx, ny, n = size(mat) #Checking to see if the box stays put when I check the same image over and over. 
# for i = 2:n
#     mat[:,:,i] = mat[:,:,1]
# end

windowsize = 32
u0 = 314
v0 = 666

ws2 = Int(windowsize/2)


# u = Array{Int, 1}(undef, n)
# v = Array{Int, 1}(undef, n)
# phi = Array{Float64, 2}(undef, windowsize+1, windowsize+1)
    

#Set x0 in x
u[1] = u0
v[1] = v0

xidx1 = u0 - ws2
xidx2 = u0 + ws2
yidx1 = v0 - ws2
yidx2 = v0 + ws2

invert = false
i = 4

if invert
    IW1 = 1.0 .- mat[xidx1:xidx2, yidx1:yidx2, i-1]
    IW2 = 1.0 .- mat[xidx1:xidx2, yidx1:yidx2, i]
else
    IW1 = mat[xidx1:xidx2, yidx1:yidx2, i-1]
    IW2 = mat[xidx1:xidx2, yidx1:yidx2, i]
end

phi = dlt.phimatrix(IW1, IW2)

_, idx = findmax(phi)

M, N = size(phi)

x0 = ceil(Int64, N/2)
y0 = ceil(Int64, M/2)

delx = idx[2] - x0 
dely = -(idx[1] - y0)

dx, dy = dlt.getdisplacement(phi)
u[i] = u0 + dx
v[i] = v0 + dy

@show delx, dx
@show dely, dy

xwin = [xidx1, xidx2, xidx2, xidx1, xidx1]
ywin = [yidx1, yidx1, yidx2, yidx2, yidx1]

plt = plot(Gray.(mat[:,:,i]), leg=false)
plot!(xwin, ywin, linecolor=:red)
scatter!(u, v, markershape=:x, markercolor=:red)
display(plt)


nothing