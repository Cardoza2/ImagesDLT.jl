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

mat = preprocess(images, Contrast(1.5))

# @show minimum(mat)

filterimage!(mat)

# nx, ny, n = size(mat) #Checking to see if the box stays put when I check the same image over and over. 
# for i = 2:n
#     mat[:,:,i] = mat[:,:,1]
# end


windowsize = 32
u0 = 314
v0 = 664



ul, vl = track(mat, u0, v0, windowsize; plotflag=true, invert=false)