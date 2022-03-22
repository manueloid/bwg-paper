using Plots, DelimitedFiles
datalabel = Dict(
    1 => ["data/robustness_order1_5.dat", "Order1"],
    2 => ["data/robustness_order2_5.dat", "Order2"],
    3 => ["data/robustness_order3_5.dat", "Order3"],
    4 => ["data/robustness_order4_5.dat", "Order4"],
)
function focusing(central_k0, data_array)
	index = findfirst(isequal(central_k0), data_array)[1]
	nwidth = 1
	filtered_matrix = data_array[index - nwidth : index + nwidth , :]
	return filtered_matrix 
end
color = (
    colorant"#0547d5",
    colorant"#dd2700",
    colorant"#05ae41",
    colorant"#ffa550",
    colorant"#000000",
)
dashses = [
    "on 5pt off 3 pt",
    "on 1pt off 1pt",
    "on 10pt off 0pt",
    "on 5pt off 1pt on 1pt off 1pt ",
    "on 3pt off 1pt",
]
marks = [ 
	 "x",
	 "o", 
	 "*",
	 "square"

]
##
function robustness(order)
	devs = []
	knots = []
	index = 2
	for k0 in 100:100:1000
		global 	fid = readdlm(datalabel[order][1])
		focused = focusing(k0, fid)
		k = focused[:,1]
		fid = focused[:,2]
		sd = (fid[index + 1] -2fid[index] + fid[index-1])/(k[index] - k[index - 1])^2
		push!(devs, sd)
		push!(knots, k0)
	end
	return knots, devs
end

using PGFPlotsX 
ax = @pgf Axis({
		legend_style = {"draw = none"},
		x_tick_label_style = raw"/pgf/number format/1000 sep = {}",
		xlabel = raw"$k_{0} R$",
		ylabel = raw"$\partial^{2}_{k}F$",
		ylabel_style = "rotate = -90",
		})
for order in 1:4
	coor = Coordinates(robustness(order)[1], robustness(order)[2])
	pl = @pgf Plot({
			color = color[order],
			line_width = " 1.4 pt",
			dash_pattern = dashses[order + 1],
			mark_options = "solid",
			mark = marks[order],
			mark_size = " 1.8 pt",
			},
		       coor)
	leg= @pgf LegendEntry("\$\\Gamma_{$order}\$ ")
	push!(ax, pl)
end
pgfsave("../gfx/robustness.pdf", ax)
##
