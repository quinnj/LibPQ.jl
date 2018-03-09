using BinaryProvider

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))

# This is the library we care about
products = Product[
    LibraryProduct(prefix, "libpq", :LIBPQ_HANDLE),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/invenia/LibPQBuilder/releases/download/v10.3-1-2"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:i686, :glibc)    => ("$bin_prefix/libpq.i686-linux-gnu.tar.gz", "404c87116702852563b6ce84b6b2937b3d8f17c23cbd7ee37d1b2405e4bdb37b"),
    Linux(:x86_64, :glibc)  => ("$bin_prefix/libpq.x86_64-linux-gnu.tar.gz", "17f00992491b58474074d036c7893e4d5b6b31a1484aba6faa44ab171421f5d5"),
    MacOS()                 => ("$bin_prefix/libpq.x86_64-apple-darwin14.tar.gz", "ead346b850704b18fe0ef2a9b4f06fb5b7699762243b00662a752d75cda7c9af"),
    Windows(:i686)          => ("$bin_prefix/libpq.i686-w64-mingw32.tar.gz", "196c1dea74b737664f429bebae994f8bab62afe09a50a11a81a269a627e60ad1"),
    Windows(:x86_64)        => ("$bin_prefix/libpq.x86_64-w64-mingw32.tar.gz", "51b7688fd997623750abd156c1d407102bd37e9ee6be3b199626abf5858802bc"),
)
# First, check to see if we're all satisfied
if any(!satisfied(p; verbose=verbose) for p in products)
    if platform_key() in keys(download_info)
        # Download and install binaries
        url, tarball_hash = download_info[platform_key()]
        install(url, tarball_hash; prefix=prefix, force=true, verbose=true)
    else
        error("Your platform $(Sys.MACHINE) is not supported by this package!")
    end

    # Finally, write out a deps.jl file
    write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
end