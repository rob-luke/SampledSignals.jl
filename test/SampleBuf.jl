@testset "SampleBuf Tests" begin
    TEST_SR = 48000
    TEST_T = Float32
    const StereoBuf = TimeSampleBuf{2, TEST_SR, TEST_T}

    @testset "SampleBuf supports size()" begin
        buf = StereoBuf(zeros(TEST_T, 64, 2))
        @test size(buf) == (64, 2)
    end

    @testset "TimeSampleBuf can be indexed with 1D indices" begin
        buf = StereoBuf(zeros(TEST_T, 64, 2))
        buf[15, 2] = 1.5
        @test buf[20] == 0.0
        @test buf[64+15] == 1.5
    end

    @testset "TimeSampleBuf can be indexed with 2D indices" begin
        buf = StereoBuf(zeros(TEST_T, 64, 2))
        buf[15, 2] = 1.5
        @test buf[15, 1] == 0.0
        @test buf[15, 2] == 1.5
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

    # @testset "supports equality" begin
    #     arr1 = rand(TEST_T, (64, 2))
    #     arr2 = arr1 + 1
    #     arr3 = arr1[:, 1]
    #     buf1 = TimeSampleBuf(arr1, TEST_SR)
    #     buf2 = TimeSampleBuf(arr1, TEST_SR)
    #     buf3 = TimeSampleBuf(arr1, TEST_SR+1)
    #     buf4 = TimeSampleBuf(arr2, TEST_SR)
    #     buf5 = TimeSampleBuf(arr3, TEST_SR)
    #     @test buf1 == buf2
    #     @test buf2 != buf3
    #     @test buf2 != buf4
    #     @test buf2 != buf5
    # end

    # @testset "TimeSampleBufs can be range-indexed in seconds" begin
    #     # array with 1s of audio
    #     arr = rand(TEST_T, (TEST_SR, 2))
    #     buf = TimeSampleBuf(arr, TEST_SR)
    #     expected_arr = arr[round(Int, TEST_SR*0.25):round(Int, TEST_SR*0.5), :]
    #     @test buf[0.25s:0.5s, :] == TimeSampleBuf(expected_arr)
    # end

end
