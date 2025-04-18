using ArgParse # Might switch to some other package
using LeakageAssessment
using LeakageAssessment: loaddata

function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table! s begin
        #"--output"
        #    help = "file name for SNR.png result"
        "--ppc"
            arg_type = Int
            default  = 0
            help     = "points per clock"
        "--bytes"
            arg_type = Int
            nargs    = '+'
            help     = "bytes to be processed"
        "textin"
            help     = "textin (textin.h5 file)"
            required = true
        "traces"
            help     = "traces (traces.h5 file)"
            required = true
    end
    return parse_args(s)
end

function main()
    # parse arguments
    args = parse_commandline()

    # load data
    traces = loaddata(args["traces"])
    textin = loaddata(args["textin"])
    if ndims(traces) == 3 # testing dataset...
        a,b,c = size(traces)
        traces = reshape(traces,  a,b*c)
        a,c   = size(textin)
        textin = reshape(textin,a÷b,b*c)
    end
    textin = isempty(args["bytes"]) ? textin : view(textin,args["bytes"],:)

    # run SNR
    snrs = SNR(textin, traces)

    # plot SNR
    println("plotting SNR result...                  \r")
    plotSNR(snrs, traces; block=true, ppc=args["ppc"])
end


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
