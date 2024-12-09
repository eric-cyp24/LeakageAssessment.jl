using ArgParse # Might switch to some other package
using LeakageAssessment
using LeakageAssessment: loaddata

function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table! s begin
        #"--output"
        #    help = "file name for SNR.png result"
        "--bytes"
            arg_type = Int
            nargs = '+'
            help = "bytes to be processed"
        "textin"
            help = "textin (.npy file)"
            required = true
        "traces"
            help = "traces (.npy file)"
            required = true
    end
    return parse_args(s)
end

function main()
    # parse arguments
    args = parse_commandline()

    # load data
    traces = loaddata(args["traces"]; datapath="data")
    textin = loaddata(args["textin"]; datapath="data")
    if ndims(traces) == 3 # testing dataset...
        a,b,c = size(traces)
        traces = reshape(traces,  a,b*c)
        println("traces size: $((a,b,c)) -> reshape to $(size(traces))")
        a,c   = size(textin)
        textin = reshape(textin,a÷b,b*c)
    end
    textin = isempty(args["bytes"]) ? textin : view(textin,args["bytes"],:)

    # run NICV
    nicvs = NICV(textin, traces)
    if !isempty(args["bytes"]) nicvs = Dict("byte $b"=>nicv for (b,nicv) in zip(args["bytes"],eachcol(nicvs))) end

    # plot NICV
    println("plotting NICV result...                  \r")
    plotNICV(nicvs, traces)
end


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
