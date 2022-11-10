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

images = [load(img) for img in files]

mat = preprocess(images)

# @show maximum(mat)
# @show minimum(mat)

dlt.filter!(mat)

# anim = @animate for i = 1:length(files)
#     plot(Gray.(mat[:,:,i]))
# end

# gif(anim, "anim_fps03.gif", fps = 10)


xlim = (0, 1024)
ylim = (0, 1024)

blobs = blob_LoG(mat[:,:,20], [100])

xpt = [blobs[end-2].location[1]]
ypt = [blobs[end-2].location[2]]

plt1 = plot(Gray.(mat[:,:,20]), leg=false, xlims=xlim, ylims=ylim)
scatter!(xpt, ypt)
display(plt1)

