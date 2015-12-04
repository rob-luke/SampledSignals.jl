@testset "SampleBuf Tests" begin
    TEST_SR = 48000//1
    TEST_T = Float32
    const StereoBuf = TimeSampleBuf{2, TEST_SR, TEST_T}
    const StereoFBuf = FrequencySampleBuf{2, TEST_SR, TEST_T}

    @testset "Supports audio interface" begin
        tbuf = StereoBuf(zeros(TEST_T, 64, 2))
        fbuf = StereoFBuf(zeros(TEST_T, 64, 2))
        @test samplerate(tbuf) == TEST_SR
        @test nchannels(tbuf) == 2
        @test nframes(tbuf) == 64
        @test samplerate(fbuf) == TEST_SR
        @test nchannels(fbuf) == 2
        @test nframes(fbuf) == 64
    end

    @testset "Supports size()" begin
        buf = StereoBuf(zeros(TEST_T, 64, 2))
        @test size(buf) == (64, 2)
    end

    @testset "Can get type params from contained array" begin
        timebuf = TimeSampleBuf(Array(TEST_T, 32, 2), TEST_SR)
        @test typeof(timebuf) == TimeSampleBuf{2, TEST_SR, TEST_T}
        monotimebuf = TimeSampleBuf(Array(TEST_T, 32), TEST_SR)
        @test typeof(monotimebuf) == TimeSampleBuf{1, TEST_SR, TEST_T}
        freqbuf = FrequencySampleBuf(Array(TEST_T, 32, 2), TEST_SR)
        @test typeof(freqbuf) == FrequencySampleBuf{2, TEST_SR, TEST_T}
        monofreqbuf = FrequencySampleBuf(Array(TEST_T, 32), TEST_SR)
        @test typeof(monofreqbuf) == FrequencySampleBuf{1, TEST_SR, TEST_T}
    end

    @testset "supports equality" begin
        arr1 = rand(TEST_T, (64, 2))
        arr2 = arr1 + 1
        arr3 = arr1[:, 1]
        buf1 = TimeSampleBuf(arr1, TEST_SR)
        buf2 = TimeSampleBuf(arr1, TEST_SR)
        buf3 = TimeSampleBuf(arr1, TEST_SR+1)
        buf4 = TimeSampleBuf(arr2, TEST_SR)
        buf5 = TimeSampleBuf(arr3, TEST_SR)
        buf6 = FrequencySampleBuf(arr1, TEST_SR)
        @test buf1 == buf2
        @test buf2 != buf3
        @test buf2 != buf4
        @test buf2 != buf5
        @test buf1 != buf6
    end


    @testset "Can be indexed with 1D indices" begin
        arr = TEST_T[1:8 9:16]
        buf = TimeSampleBuf(arr, TEST_SR)
        buf[12] = 1.5
        @test buf[12] == 1.5

        arr = TEST_T[1:8 9:16]
        buf = FrequencySampleBuf(arr, TEST_SR)
        buf[12] = 1.5
        @test buf[12] == 1.5
    end

    @testset "Can be indexed with 2D indices" begin
        arr = TEST_T[1:8 9:16]
        buf = TimeSampleBuf(arr, TEST_SR)
        buf[5, 2] = 1.5
        @test buf[5, 2] == 1.5

        arr = TEST_T[1:8 9:16]
        buf = FrequencySampleBuf(arr, TEST_SR)
        buf[5, 2] = 1.5
        @test buf[5, 2] == 1.5
    end

    @testset "Can be indexed with 1D ranges" begin
        arr = TEST_T[1:8 9:16]
        buf = TimeSampleBuf(arr, TEST_SR)
        # linear indexing gives you a mono buffer
        slice = buf[6:12]
        @test typeof(slice) == TimeSampleBuf{1, TEST_SR, TEST_T}
        @test slice == TimeSampleBuf(TEST_T[6:12;], TEST_SR)
        @test typeof(buf[:]) == TimeSampleBuf{1, TEST_SR, TEST_T}
        @test buf[:] == TimeSampleBuf(arr[:], TEST_SR)

        buf = FrequencySampleBuf(arr, TEST_SR)
        # linear indexing gives you a mono buffer
        slice = buf[6:12]
        @test typeof(slice) == FrequencySampleBuf{1, TEST_SR, TEST_T}
        @test slice == FrequencySampleBuf(TEST_T[6:12;], TEST_SR)
        @test typeof(buf[:]) == FrequencySampleBuf{1, TEST_SR, TEST_T}
        @test buf[:] == FrequencySampleBuf(arr[:], TEST_SR)
    end

    @testset "can be indexed with 2D ranges" begin
        arr = TEST_T[1:8 9:16]
        buf = TimeSampleBuf(arr, TEST_SR)
        slice = buf[3:6, 1:2]
        @test typeof(slice) == TimeSampleBuf{2, TEST_SR, TEST_T}
        @test slice == TimeSampleBuf(TEST_T[3:6 11:14], TEST_SR)
        # make sure it works with a bare colon
        slice = buf[3:6, :]
        @test typeof(slice) == TimeSampleBuf{2, TEST_SR, TEST_T}
        @test slice == TimeSampleBuf(TEST_T[3:6 11:14], TEST_SR)
        slice = buf[:, 1:2]
        @test typeof(slice) == TimeSampleBuf{2, TEST_SR, TEST_T}
        @test slice == TimeSampleBuf(TEST_T[1:8 9:16], TEST_SR)
        slice = buf[:, :]
        @test typeof(slice) == TimeSampleBuf{2, TEST_SR, TEST_T}
        @test slice == TimeSampleBuf(TEST_T[1:8 9:16], TEST_SR)

        buf = FrequencySampleBuf(arr, TEST_SR)
        slice = buf[3:6, 1:2]
        @test typeof(slice) == FrequencySampleBuf{2, TEST_SR, TEST_T}
        @test slice == FrequencySampleBuf(TEST_T[3:6 11:14], TEST_SR)
        # make sure it works with a bare colon
        slice = buf[3:6, :]
        @test typeof(slice) == FrequencySampleBuf{2, TEST_SR, TEST_T}
        @test slice == FrequencySampleBuf(TEST_T[3:6 11:14], TEST_SR)
        slice = buf[:, 1:2]
        @test typeof(slice) == FrequencySampleBuf{2, TEST_SR, TEST_T}
        @test slice == FrequencySampleBuf(TEST_T[1:8 9:16], TEST_SR)
        slice = buf[:, :]
        @test typeof(slice) == FrequencySampleBuf{2, TEST_SR, TEST_T}
        @test slice == FrequencySampleBuf(TEST_T[1:8 9:16], TEST_SR)
    end

    @testset "can be sliced in 1D" begin
        arr = TEST_T[1:8 9:16]
        buf = TimeSampleBuf(arr, TEST_SR)
        slice = buf[6, 1:2]
        @test typeof(slice) == TimeSampleBuf{2, TEST_SR, TEST_T}
        @test slice == TimeSampleBuf(TEST_T[6 14], TEST_SR)
        @test buf[6, 1:2] == buf[6:6, 1:2]
        slice = buf[3:6, 1]
        @test typeof(slice) == TimeSampleBuf{1, TEST_SR, TEST_T}
        @test slice == TimeSampleBuf(TEST_T[3:6;], TEST_SR)
        # note this behavior ends up different than a normal array, because we
        # always store the data as a 2D array
        @test buf[3:6, 1] == buf[3:6, 1:1]

        buf = FrequencySampleBuf(arr, TEST_SR)
        slice = buf[6, 1:2]
        @test typeof(slice) == FrequencySampleBuf{2, TEST_SR, TEST_T}
        @test slice == FrequencySampleBuf(TEST_T[6 14], TEST_SR)
        @test buf[6, 1:2] == buf[6:6, 1:2]
        slice = buf[3:6, 1]
        @test typeof(slice) == FrequencySampleBuf{1, TEST_SR, TEST_T}
        @test slice == FrequencySampleBuf(TEST_T[3:6;], TEST_SR)
        # note this behavior ends up different than a normal array, because we
        # always store the data as a 2D array
        @test buf[3:6, 1] == buf[3:6, 1:1]
    end

    @testset "can be indexed with Intervals" begin
        arr = TEST_T[1:8 9:16]
        buf = TimeSampleBuf(arr, TEST_SR)
        # linear indexing gives you a mono buffer
        slice = buf[6..12]
        @test typeof(slice) == TimeSampleBuf{1, TEST_SR, TEST_T}
        @test slice == TimeSampleBuf(arr[6:12], TEST_SR)
        slice = buf[2..6, 1]
        @test typeof(slice) == TimeSampleBuf{1, TEST_SR, TEST_T}
        @test slice == TimeSampleBuf(arr[2:6, 1], TEST_SR)
        slice = buf[2, 1..2]
        @test typeof(slice) == TimeSampleBuf{2, TEST_SR, TEST_T}
        # 0.5 array indexing drops scalar indices, so we use 2:2 instead of 2
        @test slice == TimeSampleBuf(arr[2:2, 1:2], TEST_SR)
        slice = buf[2..6, 1..2]
        @test typeof(slice) == TimeSampleBuf{2, TEST_SR, TEST_T}
        @test slice == TimeSampleBuf(arr[2:6, 1:2], TEST_SR)

        buf = FrequencySampleBuf(arr, TEST_SR)
        # linear indexing gives you a mono buffer
        slice = buf[6..12]
        @test typeof(slice) == FrequencySampleBuf{1, TEST_SR, TEST_T}
        @test slice == FrequencySampleBuf(arr[6:12], TEST_SR)
        slice = buf[2..6, 1]
        @test typeof(slice) == FrequencySampleBuf{1, TEST_SR, TEST_T}
        @test slice == FrequencySampleBuf(arr[2:6, 1], TEST_SR)
    end

    @testset "Can be indexed with bool arrays" begin
        arr = TEST_T[1:8;]
        buf = TimeSampleBuf(arr, TEST_SR)
        idxs = falses(length(buf))
        idxs[[1, 3, 5]] = true
        arr[idxs]
        @test buf[idxs] == TimeSampleBuf(arr[idxs], TEST_SR)
    end

    @testset "Checksize works" begin
        arr = TEST_T[1:8;]
        buf = TimeSampleBuf(arr, TEST_SR)
        @test_throws DimensionMismatch Base.checksize(buf, zeros(4))
        @test Base.checksize(buf, trues(size(buf))) == nothing
        @test_throws DimensionMismatch Base.checksize(buf, falses(4))
    end

    @testset "Invalid units throw an error" begin
        arr = rand(TEST_T, (round(Int, 0.01*TEST_SR), 2))
        buf = TimeSampleBuf(arr, TEST_SR)
        @test_throws ArgumentError buf[1*SIUnits.Ampere]
    end

    @testset "TimeSampleBufs can be indexed in seconds" begin
        # array with 10ms of audio
        arr = rand(TEST_T, (round(Int, 0.01*TEST_SR), 2))
        buf = TimeSampleBuf(arr, TEST_SR)
        @test buf[0.0s] == arr[1]
        @test buf[0.005s] == arr[241]
        @test buf[0.005s, 1] == arr[241, 1]
        @test buf[0.005s, 2] == arr[241, 2]
        @test buf[0.004s..0.005s] == TimeSampleBuf(arr[193:241], TEST_SR)
        @test buf[0.004s..0.005s, 2] == TimeSampleBuf(arr[193:241, 2], TEST_SR)
        @test buf[0.004s..0.005s, 1:2] == TimeSampleBuf(arr[193:241, 1:2], TEST_SR)
    end

    @testset "FrequencySampleBufs can be indexed in Hz" begin
        N = 512
        arr = rand(TEST_T, N, 2)
        buf = FrequencySampleBuf(arr, N / TEST_SR)
        @test buf[0.0Hz] == arr[1]
        @test buf[843.75Hz] == arr[10]
        @test buf[843.75Hz, 1] == arr[10, 1]
        @test buf[843.75Hz, 2] == arr[10, 2]
    end

    @testset "Supports arithmetic" begin
        arr1 = rand(TEST_T, 512, 2)
        arr2 = rand(TEST_T, 512, 2)
        buf1 = TimeSampleBuf(arr1, TEST_SR)
        buf2 = TimeSampleBuf(arr2, TEST_SR)

        @test buf1 + 1 == TimeSampleBuf(arr1 + 1, TEST_SR)
        @test buf1 + buf2 == TimeSampleBuf(arr1 + arr2, TEST_SR)
    end

    @testset "FFT of TimeSampleBuf gives FrequencySampleBuf" begin
        arr = rand(TEST_T, 512)
        buf = TimeSampleBuf(arr, TEST_SR)
        spec = fft(buf)
        @test typeof(spec) == FrequencySampleBuf{1, 512//TEST_SR, Complex{TEST_T}}
        @test spec == FrequencySampleBuf(fft(arr), 512//TEST_SR)
        buf2 = ifft(spec)
        # TODO: real time signals should become symmetric spectra, and then
        # back to real time signals with ifft
        @test typeof(buf2) == TimeSampleBuf{1, TEST_SR, Complex{TEST_T}}
        @test isapprox(buf2, buf)
    end
end
