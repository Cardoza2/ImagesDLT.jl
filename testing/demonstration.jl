using ImagesDLT, Images, Plots, LaTeXStrings

dlt = ImagesDLT

currentdir = @__DIR__

cd(currentdir)


#Image 1 Camera 1
xl1 = [0, 0, 4, 4, 2].*.75
yl1 = [0, 4, 4, 0, 2].*.75
zl1 = [0, 0, 0, 0, 0]
ul1 = [334, 332, 844, 848, 594]
vl1 = [810, 284, 285, 797, 543]

#Image 2 Camera 1
xl2 = [0, 0, 4, 4, 2].*.75
yl2 = [0, 4, 4, 0, 2].*.75
zl2 = [1, 1, 1, 1, 1]
ul2 = [314, 312, 806, 810, 564]
vl2 = [798, 290, 294, 786, 541]

#Image 3 Camera 1
xl3 = [0, 0, 4, 4, 2].*.75
yl3 = [0, 4, 4, 0, 2].*.75
zl3 = [2, 2, 2, 2, 2]
ul3 = [292, 289, 770, 772, 534]
vl3 = [786, 297, 298, 776, 539]

#Image 4 Camera 1
xl4 = [0, 0, 4, 4, 2].*.75
yl4 = [0, 4, 4, 0, 2].*.75
zl4 = [3, 3, 3, 3, 3]
ul4 = [274, 270, 736, 738, 506]
vl4 = [778, 303, 304, 766, 536]

#Image 1 Camera 2
xr1 = [0, 0, 4, 4, 2].*.75
yr1 = [0, 4, 4, 0, 2].*.75
zr1 = [0, 0, 0, 0, 0]
ur1 = [238, 230, 730, 738, 478]
vr1 = [796, 296, 278, 802, 542]

#Image 2 Camera 2
xr2 = [0, 0, 4, 4, 2].*.75
yr2 = [0, 4, 4, 0, 2].*.75
zr2 = [1, 1, 1, 1, 1]
ur2 = [276, 268, 754, 762, 510]
vr2 = [786, 302, 284, 788, 538]

#Image 3 Camera 2
xr3 = [0, 0, 4, 4, 2].*.75
yr3 = [0, 4, 4, 0, 2].*.75
zr3 = [2, 2, 2, 2, 2]
ur3 = [310, 304, 774, 782, 538]
vr3 = [776, 310, 292, 780, 538]

#Image 4 Camera 2
xr4 = [0, 0, 4, 4, 2].*.75
yr4 = [0, 4, 4, 0, 2].*.75
zr4 = [3, 3, 3, 3, 3]
ur4 = [346, 338, 792, 802, 566]
vr4 = [768, 315, 298, 772, 536]

xl = vcat(xl1, xl2, xl3, xl4)
yl = vcat(yl1, yl2, yl3, yl4)
zl = vcat(zl1, zl2, zl3, zl4)
ul = vcat(ul1, ul2, ul3, ul4)
vl = vcat(vl1, vl2, vl3, vl4)

xr = vcat(xr1, xr2, xr3, xr4)
yr = vcat(yr1, yr2, yr3, yr4)
zr = vcat(zr1, zr2, zr3, zr4)
ur = vcat(ur1, ur2, ur3, ur4)
vr = vcat(vr1, vr2, vr3, vr4)

L = FGsolve(xl, yl, zl, ul, vl) 
R = FGsolve(xr, yr, zr, ur, vr)


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

images = [load(img) for img in files]

mat = preprocess(images, Contrast(1.5))

filterimage!(mat)

windowsize = 32
u0 = 314
v0 = 662

pltl = plot(Gray.(mat[:,:,1]))
scatter!([u0], [v0], markershape=:x, markercolor=:red)
display(pltl)

ul, vl = track(mat, u0, v0, windowsize; plotflag=false, invert=false)


### Camera 2
filepath = "../data/data_Camera2/"

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

images = [load(img) for img in files]

mat = preprocess(images, Contrast(1.5))

filterimage!(mat)

windowsize = 32
u0 = 362
v0 = 657

pltr = plot(Gray.(mat[:,:,1]))
scatter!([u0], [v0], markershape=:x, markercolor=:red)
display(pltr)

ur, vr = track(mat, u0, v0, windowsize; plotflag=false, invert=false)


n = length(files)

x = Array{Float64, 1}(undef, n)
y = Array{Float64, 1}(undef, n)
z = Array{Float64, 1}(undef, n)

for i = 1:n
    x[i], y[i], z[i] = xyz_position(ul[i], vl[i], ur[i], vr[i], L, R)
end

# pltx = plot(x, xaxis="Time (frame)", yaxis="Position (in)", title="X Position", leg=false)
# plty = plot(y, xaxis="Time (frame)", yaxis="Position (in)", title="Y Position", leg=false)
# pltz = plot(z, xaxis="Time (frame)", yaxis="Position (in)", title="Z Position", leg=false)

# pplt = plot(pltx, plty, pltz, layout=(1,3))
# display(pplt)
# savefig("2Dpositions.png")

# plt3d = plot(x, y, z, xaxis="X (in)", yaxis="Y (in)", zaxis="Z (in)", camera=(45, 45), leg=false, markershape=:x, seriescolor=:red)
# display(plt3d)
# savefig("3Dpath.png")






vx = zeros(n-1)
vy = zeros(n-1)
vz = zeros(n-1)

for i = 1:n-1
    vx[i] = x[i+1]-x[i]
    vy[i] = y[i+1]-y[i]
    vz[i] = z[i+1]-z[i]
end

# pltx = plot(vx, xaxis="Time (frame)", yaxis=L"Velocity $\left(\frac{in}{frame}\right)$", title="X", leg=false)
# plty = plot(vy, xaxis="Time (frame)", yaxis=L"Velocity $\left(\frac{in}{frame}\right)$", title="Y", leg=false)
# pltz = plot(vz, xaxis="Time (frame)", yaxis=L"Velocity $\left(\frac{in}{frame}\right)$", title="Z", leg=false)

# vplt = plot(pltx, plty, pltz, layout=(1,3), left_margin=8mm, right_margin=8mm, top_margin=8mm, size=(1000,600))
# display(vplt)
# savefig("2Dvelocities.png")

