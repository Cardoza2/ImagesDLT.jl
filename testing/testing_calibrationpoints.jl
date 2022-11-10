#=
Here I'm going to test finding calibration points. I originally thought about having a function to do this, but I might just use Plots or Makie, or possibly Images

=#


using ImagesDLT, Images, Plots, Statistics, Plots.PlotMeasures

dlt = ImagesDLT

currentdir = @__DIR__

cd(currentdir)

filepath = "../data/Calibration_Camera1/"

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

mat = preprocess(images)

### No great option available in Julia. Using MATLAB for sake of time to get my calibration points. 

### Points from MATLAB ginput()
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



# plt = plot(images[1])
# scatter!(ul1, vl1, markercolor=:red, leg=false, xaxis="X Position (pixels)", yaxis="Y Position (pixels)", xlims=(-50, 1100), left_margin=1mm)
# display(plt)
# savefig("2Dcalibrationpoints.png")


L = FGsolve(xl, yl, zl, ul, vl) 
R = FGsolve(xr, yr, zr, ur, vr)

n = length(ul)

x = Array{Float64, 1}(undef, n)
y = Array{Float64, 1}(undef, n)
z = Array{Float64, 1}(undef, n)

for i = 1:n
    x[i], y[i], z[i] = xyz_position(ul[i], vl[i], ur[i], vr[i], L, R)
end

# calptsplt = scatter(x, y, z, camera=(35, 50), xaxis="X Position (in)", yaxis="Y Position (in)", zaxis="Z Position (in)", leg=false, markercolor=:red, size=(500, 500))
# display(calptsplt)
# savefig("3Dcalibrationpoints.png")

abserr(f, ft) = abs(f - ft)

xerr = abserr.(x, xl)
yerr = abserr.(y, yl)
zerr = abserr.(z, zl)

tab = hcat(xl, x, xerr, yl, y, yerr, zl, z, zerr)

# @show mean(xerr), mean(yerr), mean(zerr)
# @show median(xerr), median(yerr), median(zerr)

# n, m = size(tab)

# println("")
# println("x & x approx & x error & y & y approx & y error & z & z approx & z error\\\\")
# for i = 1:n
#     line = ""
#     for j = 1:m
#         val = round(tab[i,j], digits=3)
#         if j==m
#             line *= "$val \\\\"
#         else
#             line *= "$val & "
#         end
#     end
#     println(line)
# end

println("")
println("")
println("")
println(" L & R \\\\")
for i = 1:11
    lval = round(L[i], digits=3)
    rval = round(R[i], digits=3)
    println("$lval & $rval \\\\")
end

nothing