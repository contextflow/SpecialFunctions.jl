# This file contains code that was formerly a part of Julia. License is MIT: http://julialang.org/license

using SpecialFunctions
using Test
using Base.MathConstants: γ

using SpecialFunctions: AmosException, f64

# useful test functions for relative error, which differ from isapprox
# in that relerrc separately looks at the real and imaginary parts
relerr(z, x) = z == x ? 0.0 : abs(z - x) / abs(x)
relerrc(z, x) = max(relerr(real(z),real(x)), relerr(imag(z),imag(x)))
≅(a,b) = relerrc(a,b) ≤ 1e-13

@testset "error functions" begin
    @test erf(Float16(1)) ≈ 0.84270079294971486934
    @test erf(1) ≈ 0.84270079294971486934
    @test erfc(1) ≈ 0.15729920705028513066
    @test erfc(Float16(1)) ≈ 0.15729920705028513066
    @test erfcx(1) ≈ 0.42758357615580700442
    @test erfcx(Float32(1)) ≈ 0.42758357615580700442
    @test erfcx(Complex{Float32}(1)) ≈ 0.42758357615580700442
    @test erfi(1) ≈ 1.6504257587975428760
    @test erfinv(0.84270079294971486934) ≈ 1
    @test erfcinv(0.15729920705028513066) ≈ 1
    @test dawson(1) ≈ 0.53807950691276841914

    @test erf(1+2im) ≈ -0.53664356577856503399-5.0491437034470346695im
    @test erfc(1+2im) ≈ 1.5366435657785650340+5.0491437034470346695im
    @test erfcx(1+2im) ≈ 0.14023958136627794370-0.22221344017989910261im
    @test erfi(1+2im) ≈ -0.011259006028815025076+1.0036063427256517509im
    @test dawson(1+2im) ≈ -13.388927316482919244-11.828715103889593303im

    for elty in [Float32,Float64]
        for x in exp10.(range(-200, stop=-0.01, length=50))
            @test isapprox(erf(erfinv(x)), x, atol=1e-12*x)
            @test isapprox(erf(erfinv(-x)), -x, atol=1e-12*x)
            @test isapprox(erfc(erfcinv(2*x)), 2*x, atol=1e-12*x)
            if x > 1e-20
                xf = Float32(x)
                @test isapprox(erf(erfinv(xf)), xf, atol=1e-5*xf)
                @test isapprox(erf(erfinv(-xf)), -xf, atol=1e-5*xf)
                @test isapprox(erfc(erfcinv(2xf)), 2xf, atol=1e-5*xf)
            end
        end
        @test erfinv(one(elty)) == Inf
        @test erfinv(-one(elty)) == -Inf
        @test_throws DomainError erfinv(convert(elty,2.0))

        @test erfcinv(zero(elty)) == Inf
        @test_throws DomainError erfcinv(-one(elty))
    end

    @test erfinv(one(Int)) == erfinv(1.0)
    @test erfcinv(one(Int)) == erfcinv(1.0)

    @test erfcx(1.8) ≈ erfcx(big(1.8)) rtol=4*eps()
    @test erfcx(1.8e8) ≈ erfcx(big(1.8e8)) rtol=4*eps()
    @test erfcx(1.8e88) ≈ erfcx(big(1.8e88)) rtol=4*eps()

    @test_throws MethodError erf(big(1.0)*im)
    @test_throws MethodError erfi(big(1.0))
end
@testset "incomplete gamma ratios" begin
#Computed using Wolframalpha gamma(a,x)/gamma(a) ~ gamma_q(a,x,0) function.
    @test gamma_inc(10,10,0)[2] ≈ 0.45792971447185221
    @test gamma_inc(1,1,0)[2] ≈ 0.3678794411714423216
    @test gamma_inc(0.5,0.5,0)[2] ≈ 0.31731050786291410
    @test gamma_inc(BigFloat(30.5),BigFloat(30.5),0)[2] ≈ parse(BigFloat,"0.47591691193354987004") rtol=eps()
    @test gamma_inc(5.5,0.5,0)[2] ≈ 0.9999496100513121669
    @test gamma_inc(0.5,7.4,0)[2] ≈ 0.0001195355018130302
    @test gamma_inc(0.5,0.22,0)[2] ≈ 0.507122455359825146
    @test gamma_inc(0.5,0.8,0)[2] ≈ 0.20590321073206830887
    @test gamma_inc(11.5,0.5,0)[2] ≈ 0.999999999998406112
    @test gamma_inc(0.19,0.99,0)[2] ≈ 0.050147247342905857
    @test gamma_inc(0.9999,0.9999,0)[2] ≈ 0.3678730556923103
    @test gamma_inc(24,23.9999999999,0)[2] ≈ 0.472849720555859138
    @test gamma_inc(0.5,0.55,0)[2] ≈ 0.29426610430496289
    @test gamma_inc(Float32(0.5),Float32(0.55),0)[2] ≈ Float32(gamma_inc(0.5,0.55,0)[2])
    @test gamma_inc(Float16(0.5),Float16(0.55),0)[2] ≈ Float16(gamma_inc(0.5,0.55,0)[2])
    @test gamma_inc(30,29.99999,0)[2] ≈ 0.475717712451705704
    @test gamma_inc(30,29.9,0)[2] ≈ 0.482992166284958565
    @test gamma_inc(10,0.0001,0)[2] ≈ 1.0000
    @test gamma_inc(0.0001,0.0001,0)[2] ≈ 0.000862958131006599
    @test gamma_inc(0.0001,10.5,0)[1] ≈ 0.999999999758896146
    @test gamma_inc(1,1,0)[1] ≈ 0.63212055882855768
    @test gamma_inc(13,15.1,0)[2] ≈ 0.25940814264863701
    @test gamma_inc(0.6,1.3,0)[2] ≈ 0.136458554006505355
    @test gamma_inc((100),(80),0)[2] ≈ 0.9828916869648668
    @test gamma_inc((100),(80),1)[2] ≈ 0.9828916869
    @test Float16(gamma_inc((100),(80),2)[2]) ≈ Float16(.983)
    @test gamma_inc(13.5,15.1,0)[2] ≈ 0.305242642543419087  
    @test gamma_inc(11,9,0)[1] ≈ 0.2940116796594881834
    @test gamma_inc(8,32,0)[1] ≈ 0.99999989060651042057
    @test gamma_inc(15,16,0)[2] ≈ 0.3675273597655649298
    @test gamma_inc(15.5,16,0)[2] ≈ 0.4167440299455427811
    @test gamma_inc(0.9,0.8,0)[1] ≈ 0.59832030278768172
    @test gamma_inc(1.7,2.5,0)[1] ≈ 0.78446115627678957
    @test gamma_inc(11.1,0.001,0)[2] ≈ 1.0000
    @test_throws DomainError gamma_inc(-1,2,2)
    @test_throws DomainError gamma_inc(0,0,1)
end
@testset "inverse of incomplete gamma ratios" begin
#Compared with Scipy.special.gammaincinv
    @test gamma_inc_inv(1.0,0.5,0.5) ≈ 0.69314718055994529
    ctr=1
    ans1 = [7.4153939596077105e-06, 4.1948837553001128e-05, 0.00011560348487144592, 0.00023733157806706144, 0.00041465371557152853, 0.00065420366900931063, 0.00096200074513191707, 0.0013436111982025845, 0.0018042543050560357, 0.0023488772409990069, 0.0029822108340951982, 0.0037088128669865747, 0.0045331028890989175, 0.0054593910326394268, 0.0064919024756292113, 0.0076347986776777021, 0.0088921961857776899, 0.010268183591667559, 0.011766837076460529, 0.013392234877244308, 0.015148470939019535, 0.01703966796416153, 0.019069990034434534, 0.021243654953428382, 0.02356494643740838, 0.026038226268114743, 0.028667946510727123, 0.031458661893117974, 0.034415042438025324, 0.037541886437423046, 0.040844133857854445, 0.044326880266606375, 0.047995391371211706, 0.051855118268798489, 0.055911713507252728, 0.060171048067033703, 0.064639229380863375, 0.069322620518498704, 0.074227860675536064, 0.079361887118881563, 0.084731958757381876, 0.090345681524433508, 0.09621103578051432, 0.10233640596793599, 0.10873061277817557, 0.11540294812451861, 0.12236321325012786, 0.12962176034488948, 0.13718953809449788, 0.14507814164343533, 0.15329986752124386, 0.16186777416055501, 0.17079574872787454, 0.18009858109673355, 0.18979204592069479, 0.19989299391476917, 0.21041945363284603, 0.22139074524173796, 0.23282760804678732, 0.24475234382888267, 0.25718897841979127, 0.27016344438650586, 0.28370378823436093, 0.29784040619656998, 0.3126063134848735, 0.32803745287127684, 0.34417304970517859, 0.36105602201014886, 0.37873345623790661, 0.39725716170037845, 0.41668431981048032, 0.43707824825000413, 0.45850930533751827, 0.4810559665889298, 0.50480611430358513, 0.52985859275268155, 0.55632509731250579, 0.58433248729003373, 0.61402564160686812, 0.64557101747749401, 0.67916113010215806, 0.71502025447176809, 0.75341177168885431, 0.79464776273185678, 0.83910172694543061, 0.8872257293787823, 0.93957396283390326, 0.99683583211997739, 1.0598835767754553, 1.1298428254726491, 1.2082007260001051, 1.296978498210863, 1.3990206562238474, 1.5185103158285946, 1.6619620177540984, 1.8403447442261882, 2.0743414883146705, 2.4107139457641296, 3.0000967446589719]
    ans2 = [0.0028980766274747166, 0.006908184939374363, 0.01149696382036067, 0.016518276652159908, 0.02189753286142773, 0.027589145508248085, 0.03356249352199024, 0.03979579246097344, 0.046272957709150415, 0.052981821800176826, 0.05991304249771414, 0.06705939521991744, 0.07441529398164964, 0.08197645553388541, 0.08973965716025696, 0.09770255795612678, 0.10586356446493835, 0.11422172813580914, 0.12277666614622669, 0.1315284997431042, 0.14047780597228823, 0.14962557982476085, 0.15897320462672093, 0.16852242906309764, 0.17827534962728914, 0.18823439758407795, 0.19840232975077693, 0.2087822225659563, 0.21937746904082012, 0.23019177828605702, 0.24122917738430874, 0.2524940154406757, 0.2639909696948641, 0.27572505362160177, 0.2877016269830214, 0.29992640782953106, 0.31240548647561406, 0.325145341505105, 0.33815285788768823, 0.35143534731545956, 0.36500057089608295, 0.3788567643680646, 0.3930126660346167, 0.40747754764618266, 0.4222612484987209, 0.4373742130560526, 0.4528275324509786, 0.4686329902724166, 0.48480311310582785, 0.5013512263630729, 0.5182915160173085, 0.5356390969506658, 0.5534100887296879, 0.5716216997488716, 0.5902923208297984, 0.6094416295366399, 0.6290907066738872, 0.649262166675578, 0.6699803038855925, 0.6912712570761026, 0.7131631949691678, 0.7356865260311793, 0.7588741364223205, 0.7827616607300203, 0.807387791030685, 0.832794630951811, 0.8590281028041281, 0.8861384175955134, 0.9141806199237333, 0.943215222504511, 0.9733089486005939, 1.0045356051136263, 1.0369771149071734, 1.0707247444923012, 1.1058805731481947, 1.1425592627436494, 1.1808902052215764, 1.2210201487102676, 1.2631164361809093, 1.307371036420099, 1.354005611796903, 1.4032779600790313, 1.4554903028704096, 1.5110000943860755, 1.5702343296128558, 1.633708805354231, 1.7020545444724036, 1.7760548371325608, 1.8566984660391717, 1.9452584157780999, 2.043412265612975, 2.153433912595464, 2.278514210551947, 2.4233308771016073, 2.595143613479916, 2.8061289679463384, 3.079145167578199, 3.4655956756034487, 4.12987911692835]
    ans3 = [0.1071755222650277, 0.16050998728955507, 0.20416656508566741, 0.24280678250939972, 0.27826797183157947, 0.31150317301391278, 0.34308358281638091, 0.37338428082062985, 0.40266774948514333, 0.43112656018759449, 0.45890727249428631, 0.48612476640606467, 0.51287131234095706, 0.53922256543527058, 0.5652416715299875, 0.5909821656505071, 0.61649007140344114, 0.64180545586647186, 0.66696360394811371, 0.69199592089152651, 0.71693063676844848, 0.7417933642658795, 0.76660754611766135, 0.7913948184012789, 0.81617530891938483, 0.84096788496285169, 0.86579036123554576, 0.89065967617260244, 0.91559204301304553, 0.94060308059774034, 0.96570792782021209, 0.99092134486698613, 1.0162578037796903, 1.04173157040596, 1.0673567794461716, 1.0931475040232679, 1.1191178209852426, 1.1452818729806347, 1.1716539282165654, 1.198248438708915, 1.2250800977595322, 1.2521638973416984, 1.2795151860393545, 1.3071497281656619, 1.3350837646807319, 1.363334076536002, 1.3919180510932918, 1.4208537523000897, 1.4501599953496895, 1.4798564266162111, 1.5099636097318834, 1.5405031187690257, 1.571497639604559, 1.6029710806837836, 1.6349486945666225, 1.6674572118386319, 1.7005249892070939, 1.7341821738873691, 1.7684608867260749, 1.8033954269180192, 1.839022501668433, 1.8753814847505423, 1.9125147086353582, 1.9504677957575041, 1.9892900355679812, 2.0290348153641435, 2.0697601145466438, 2.1115290740202663, 2.1544106550478053, 2.1984804051368831, 2.2438213526962998, 2.2905250575198943, 2.3386928510229508, 2.3884373090925655, 2.4398840121490508, 2.4931736625766741, 2.5484646505330266, 2.6059361873998439, 2.6657921648912399, 2.7282659516930696, 2.7936264154376702, 2.8621855665549849, 2.9343083789530127, 3.0104255776654698, 3.0910505401567816, 3.176802011280996, 3.2684352132712395, 3.3668853781968782, 3.4733301840058628, 3.5892819029224894, 3.7167280552758761, 3.8583548958347427, 4.0179202697917491, 4.2009145830871581, 4.4158272046973419, 4.6768376437172963, 5.0104347814570787, 5.4758322541221567, 6.2608605070659076]
    ans4 = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 9.793e-320, 8.8258281996309067e-311, 5.2442064082758777e-302, 2.0885820384164982e-293, 5.6626416070015106e-285, 1.0605839281955743e-276, 1.3913463845423177e-268, 1.2952838036620446e-260, 8.6636808810333524e-253, 4.2124146389233922e-245, 1.5054592477106387e-237, 3.9965668615698637e-230, 7.9602338168240791e-223, 1.20090997348131e-215, 1.3847294830684997e-208, 1.2309060164407832e-201, 8.5045125183290383e-195, 4.6029057651609662e-188, 1.9661243539196415e-181, 6.675413023480524e-175, 1.8137947775332813e-168, 3.9697776116742062e-162, 7.0423151317779386e-156, 1.0186480541842382e-149, 1.2082919222730254e-143, 1.1817770759861981e-137, 9.5806543461731422e-132, 6.4705147650865631e-126, 3.6582023269162791e-120, 1.7394045962948254e-114, 6.9867971004491818e-109, 2.3810402190694626e-103, 6.9129343541856114e-98, 1.71669965360591e-92, 3.6603939138610754e-87, 6.7261696481112057e-82, 1.0689601189656641e-76, 1.4743519045954981e-71, 1.7706253773856427e-66, 1.85749673681364e-61, 1.7074484121414459e-56, 1.3793741591778402e-51, 9.8216596440656967e-47, 6.1811283531832712e-42, 3.447488184610534e-37, 1.7085354519424486e-32, 7.5427383121540407e-28, 2.9735875496464905e-23, 1.0493212802006967e-18, 3.3220770969837717e-14, 9.4569508903874499e-10, 2.4259428385570885e-05]
    ans5 = [68.182564057578659, 70.357062784263817, 71.760877899786948, 72.829353353366415, 73.706386972437542, 74.458490388905602, 75.12219461238017, 75.719845624365121, 76.266166586236068, 76.771402301686194, 77.242986392330991, 77.686494958669414, 78.106225421683931, 78.50556502309793, 78.887234808310836, 79.253456568431432, 79.606070310177984, 79.946618932262979, 80.276410559274709, 80.596565284301676, 80.908050799453733, 81.211709956856978, 81.508282370701906, 81.798421552199031, 82.082708649987609, 82.361663579041377, 82.635754117812908, 82.905403408390271, 83.170996189584713, 83.432884016058068, 83.691389659635405, 83.946810846256611, 84.199423449687018, 84.449484238382098, 84.697233252859277, 84.942895876083071, 85.18668464780427, 85.428800864609457, 85.669436000206872, 85.908772974675117, 86.146987296778406, 86.384248099705346, 86.620719087619619, 86.856559407959935, 87.091924462499136, 87.326966668607852, 87.561836180921006, 87.796681582652582, 88.031650555063862, 88.266890533043721, 88.502549354439552, 88.738775910585431, 88.975720805449285, 89.213537031000897, 89.45238066667676, 89.692411611339708, 89.933794356792788, 90.176698812815317, 90.421301194840566, 90.667784986823875, 90.916341993645545, 91.167173499597013, 91.420491552216376, 91.676520394081336, 91.935498069297722, 92.197678236508722, 92.463332226600599, 92.732751391148227, 93.006249797557189, 93.284167339317776, 93.566873345624515, 93.854770794832618, 94.148301262289351, 94.447950766886493, 94.754256724998356, 95.067816279076155, 95.38929634645433, 95.719445839736153, 96.059110654771956, 96.409252222677836, 96.770970703934069, 97.145534304515252, 97.534416777401361, 97.939346035676579, 98.362368106482464, 98.805932668773451, 99.273009611654814, 99.767251266034179, 100.2932237698064, 100.85674648050276, 101.46540670265372, 102.12937183070848, 102.86273396770143, 103.68587349786873, 104.62994489700357, 105.74630631344544, 107.12941611870914, 108.98632200164798, 111.9556294726119]
    for x = 0.01:0.01:0.99
        @test gamma_inc_inv(0.4, x, 1.0-x) ≈ ans1[ctr]#scipy.special.gammaincinv(0.4,x)
        @test gamma_inc_inv(0.8, x, 1.0-x) ≈ ans2[ctr]#scipy.special.gammaincinv(0.8,x)
        @test gamma_inc_inv(1.8, x, 1.0-x) ≈ ans3[ctr]#scipy.special.gammaincinv(1.8,x)
        @test gamma_inc_inv(0.001, x, 1.0-x) ≈ ans4[ctr]#scipy.special.gammaincinv(.001,x)
        @test gamma_inc_inv(88.6, x, 1.0-x) ≈ ans5[ctr]#scipy.special.gammaincinv(88.6,x)
        ctr+=1
    end
    for x=-.5:.5:.9
        @test SpecialFunctions.loggamma1p(x) ≈ loggamma(1.0+x)
    end
    for x = .5:5.0:100.0
        @test SpecialFunctions.stirling(x) ≈ log(gamma(x)) - (x-.5)*log(x)+x- log(2*pi)/2.0
    end
end
@testset "elliptic integrals" begin
#Computed using Wolframalpha EllipticK and EllipticE functions.
	@test ellipk(0) ≈ 1.570796326794896619231322 rtol=2*eps()
	@test ellipk(0.92) ≈ 2.683551406315229344 rtol=2*eps()
	@test ellipk(0.5) ≈ 1.854074677301371918 rtol=2*eps()
	@test ellipk(0.01) ≈ 1.57474556151735595 rtol=2*eps()
	@test ellipk(0.45) ≈ 1.81388393681698264 rtol=2*eps()
	@test ellipk(-0.5) ≈ 1.41573720842595619 rtol=2*eps()
	@test ellipk(0.75) ≈ 2.15651564749964323 rtol=2*eps()
	@test ellipk(0.17) ≈ 1.6448064907988806 rtol=2*eps()
	@test ellipk(0.25) ≈ 1.685750354812596 rtol=2*eps()
	@test ellipk(0.69) ≈ 2.0608816467301313 rtol=2*eps()
	@test ellipk(0.84) ≈ 2.3592635547450067 rtol=2*eps()
	@test ellipe(0.15) ≈ 1.5101218320928197 rtol=2*eps()
	@test ellipe(0.21) ≈ 1.4847605813318776 rtol=2*eps()
	@test ellipe(0.42) ≈ 1.3898829914929717 rtol=2*eps()
	@test ellipe(0.66) ≈ 1.2650125751607508 rtol=2*eps()
	@test ellipe(0.76) ≈ 1.2047136418292115 rtol=2*eps()
	@test ellipe(0.865) ≈ 1.1322436887003925 rtol=2*eps()
	@test ellipe(0) ≈ 1.570796326794896619231322 rtol=2*eps()
	@test ellipe(0.8) ≈ 1.17848992432783852 rtol=2*eps()
	@test ellipe(0.5) ≈ 1.3506438810476755 rtol=2*eps()
	@test ellipe(0.01) ≈ 1.5668619420216682 rtol=2*eps()
	@test ellipe(0.99) ≈ 1.0159935450252239 rtol=2*eps()
	@test ellipe(-0.1) ≈ 1.6093590249375295 rtol=2*eps()
	@test ellipe(0.3) ≈ 1.4453630644126652 rtol=2*eps()
	@test ellipe(1.0) ≈ 1.00
	@test ellipk(1.0)==Inf
	@test_throws MethodError ellipk(BigFloat(0.5))
	@test_throws MethodError ellipe(BigFloat(-1))
	@test_throws DomainError ellipe(Float16(2.0))
	@test_throws DomainError ellipe(Float32(2.5))
end 
@testset "sine and cosine integrals" begin
    # Computed via wolframalpha.com: SinIntegral[SetPrecision[Table[x,{x, 1,20,1}],20]] and CosIntegral[SetPrecision[Table[x,{x, 1,20,1}],20]]
    sinintvals = [0.9460830703671830149, 1.605412976802694849, 1.848652527999468256, 1.75820313894905306, 1.54993124494467414, 1.4246875512805065, 1.4545966142480936, 1.5741868217069421, 1.665040075829602, 1.658347594218874, 1.578306806945727416, 1.504971241526373371, 1.499361722862824564, 1.556211050077665054, 1.618194443708368739, 1.631302268270032886, 1.590136415870701122, 1.536608096861185462, 1.518630031769363932, 1.548241701043439840]
    cosintvals = [0.3374039229009681347, 0.4229808287748649957, 0.119629786008000328, -0.14098169788693041, -0.19002974965664388, -0.06805724389324713, 0.07669527848218452, 0.122433882532010, 0.0553475313331336, -0.045456433004455, -0.08956313549547997948, -0.04978000688411367560, 0.02676412556403455504, 0.06939635592758454727, 0.04627867767436043960, -0.01420019012019002240, -0.05524268226081385053, -0.04347510299950100478, 0.00515037100842612857, 0.04441982084535331654]
    for x in 1:20
        @test sinint(x) ≅ sinintvals[x]
        @test sinint(-x) ≅ -sinintvals[x]
        @test cosint(x) ≅ cosintvals[x]
    end

    @test sinint(1.f0) == Float32(sinint(1.0))
    @test cosint(1.f0) == Float32(cosint(1.0))

    @test sinint(Float16(1.0)) == Float16(sinint(1.0))
    @test cosint(Float16(1.0)) == Float16(cosint(1.0))

    @test sinint(1//2) == sinint(0.5)
    @test cosint(1//2) == cosint(0.5)

    @test sinint(1e300) ≅ π/2
    @test cosint(1e300) ≅ -8.17881912115908554103E-301
    @test sinint(1e-300) ≅ 1.0E-300
    @test cosint(1e-300) ≅ -690.1983122333121

    @test sinint(Inf) == π/2
    @test cosint(Inf) == 0.0
    @test isnan(sinint(NaN))
    @test isnan(cosint(NaN))

    @test_throws ErrorException sinint(big(1.0))
    @test_throws ErrorException cosint(big(1.0))
    @test_throws DomainError cosint(-1.0)
    @test_throws DomainError cosint(Float32(-1.0))
    @test_throws DomainError cosint(Float16(-1.0))
    @test_throws DomainError cosint(-1//2)
end

@testset "airy" begin
    @test_throws AmosException airyai(200im)
    @test_throws AmosException airybi(200)

    for T in [Float16, Float32, Float64,Complex{Float16}, Complex{Float32},Complex{Float64}]
        @test airyai(T(1.8)) ≈ 0.0470362168668458052247
        @test airyaiprime(T(1.8)) ≈ -0.0685247801186109345638
        @test airybi(T(1.8)) ≈ 2.595869356743906290060
        @test airybiprime(T(1.8)) ≈ 2.98554005084659907283
    end
    for T in [Complex{Float16}, Complex{Float32}, Complex{Float64}]
        z = convert(T,1.8 + 1.0im)
        @test airyaix(z) ≈ airyai(z) * exp(2/3 * z * sqrt(z))
        @test airyaiprimex(z) ≈ airyaiprime(z) * exp(2/3 * z * sqrt(z))
        @test airybix(z) ≈ airybi(z) * exp(-abs(real(2/3 * z * sqrt(z))))
        @test airybiprimex(z) ≈ airybiprime(z) * exp(-abs(real(2/3 * z * sqrt(z))))
    end
    @test_throws MethodError airyai(complex(big(1.0)))

    for x = -3:3
        @test airyai(x) ≈ airyai(complex(x))
        @test airyaiprime(x) ≈ airyaiprime(complex(x))
        @test airybi(x) ≈ airybi(complex(x))
        @test airybiprime(x) ≈ airybiprime(complex(x))
        if x >= 0
            @test airyaix(x) ≈ airyaix(complex(x))
            @test airyaiprimex(x) ≈ airyaiprimex(complex(x))
        else
            @test_throws DomainError airyaix(x)
            @test_throws DomainError airyaiprimex(x)
        end
        @test airybix(x) ≈ airybix(complex(x))
        @test airybiprimex(x) ≈ airybiprimex(complex(x))
    end
end

@testset "bessel functions" begin
    bessel_funcs = [(bessely0, bessely1, bessely), (besselj0, besselj1, besselj)]
    @testset "$z, $o" for (z, o, f) in bessel_funcs
        @test z(Float32(2.0)) ≈ z(Float64(2.0))
        @test o(Float32(2.0)) ≈ o(Float64(2.0))
        @test z(Float16(2.0)) ≈ z(Float64(2.0))
        @test o(Float16(2.0)) ≈ o(Float64(2.0))
        @test z(2) ≈ z(2.0)
        @test o(2) ≈ o(2.0)
        @test z(2.0 + im) ≈ f(0, 2.0 + im)
        @test o(2.0 + im) ≈ f(1, 2.0 + im)
    end
    @testset "besselj error throwing" begin
        @test_throws MethodError besselj(1.2,big(1.0))
        @test_throws MethodError besselj(1,complex(big(1.0)))
        @test_throws MethodError besseljx(1,big(1.0))
        @test_throws MethodError besseljx(1,complex(big(1.0)))
    end
    @testset "besselh" begin
        true_h133 = 0.30906272225525164362 - 0.53854161610503161800im
        @test besselh(3,1,3) ≈ true_h133
        @test besselh(-3,1,3) ≈ -true_h133
        @test besselh(Float32(3),1,Float32(3)) ≈ true_h133	
        @test besselh(Float16(3),1,Float16(3)) ≈ true_h133
        @test besselh(3,2,3) ≈ conj(true_h133)
        @test besselh(-3,2,3) ≈ -conj(true_h133)
        @testset "Error throwing" begin
            @test_throws AmosException besselh(1,0)
            @test_throws MethodError besselh(1,big(1.0))
            @test_throws MethodError besselh(1,complex(big(1.0)))
            @test_throws MethodError besselhx(1,big(1.0))
            @test_throws MethodError besselhx(1,complex(big(1.0)))
        end
    end
    @testset "besseli" begin
        true_i33 = 0.95975362949600785698
        @test besseli(3,3) ≈ true_i33
        @test besseli(-3,3) ≈ true_i33
        @test besseli(3,-3) ≈ -true_i33
        @test besseli(-3,-3) ≈ -true_i33
        @test besseli(Float32(-3),Complex{Float32}(-3,0)) ≈ -true_i33
        @test besseli(Float16(-3),Complex{Float16}(-3,0)) ≈ -true_i33
        true_im3p1_3 = 0.84371226532586351965
        @test besseli(-3.1,3) ≈ true_im3p1_3
        for i in [-5 -3 -1 1 3 5]
            @test besseli(i,0) == 0.0
            @test besseli(i,Float32(0)) == 0
            @test besseli(i,Complex{Float32}(0)) == 0
            @test besseli(i,Float16(0)) == 0
            @test besseli(i,Complex{Float16}(0)) == 0
        end
        @testset "Error throwing" begin
            @test_throws AmosException besseli(1,1000)
            @test_throws DomainError besseli(0.4,-1.0)
            @test_throws MethodError besseli(1,big(1.0))
            @test_throws MethodError besseli(1,complex(big(1.0)))
            @test_throws MethodError besselix(1,big(1.0))
            @test_throws MethodError besselix(1,complex(big(1.0)))
        end
    end
    @testset "besselj" begin
        @test besselj(0,0) == 1
        for i in [-5 -3 -1 1 3 5]
            @test besselj(i,0) == 0
            @test besselj(i,Float32(0)) == 0
            @test besselj(i,Complex{Float32}(0)) == 0.0
        end

        j33 = besselj(3,3.)
        @test besselj(3,3) == j33
        @test besselj(-3,-3) == j33
        @test besselj(-3,3) == -j33
        @test besselj(3,-3) == -j33
        @test besselj(3,3f0) ≈ j33
        @test besselj(3,complex(3.)) ≈ j33
        @test besselj(3,complex(3f0)) ≈ j33
        @test besselj(3,complex(3)) ≈ j33

        j43 = besselj(4,3.)
        @test besselj(4,3) == j43
        @test besselj(-4,-3) == j43
        @test besselj(-4,3) == j43
        @test besselj(4,-3) == j43
        @test besselj(4,3f0) ≈ j43
        @test besselj(4,complex(3.)) ≈ j43
        @test besselj(4,complex(3f0)) ≈ j43
        @test besselj(4,complex(3)) ≈ j43

        @test j33 ≈ 0.30906272225525164362
        @test j43 ≈ 0.13203418392461221033
        @test besselj(0.1, complex(-0.4)) ≈ 0.820421842809028916 + 0.266571215948350899im
        @test besselj(3.2, 1.3+0.6im) ≈ 0.01135309305831220201 + 0.03927719044393515275im
        @test besselj(1, 3im) ≈ 3.953370217402609396im
        @test besselj(1.0,3im) ≈ besselj(1,3im)

        true_jm3p1_3 = -0.45024252862270713882
        @test besselj(-3.1,3) ≈ true_jm3p1_3
        @test besselj(Float16(-3.1),Float16(3)) ≈ true_jm3p1_3

        @testset "Error throwing" begin
            @test_throws DomainError    besselj(0.1, -0.4)
            @test_throws AmosException besselj(20,1000im)
            @test_throws MethodError besselj(big(1.0),3im)
        end
    end

    @testset "besselk" begin
        true_k33 = 0.12217037575718356792
        @test besselk(3,3) ≈ true_k33
        @test besselk(Float32(3),Float32(3)) ≈ true_k33
        @test besselk(Float16(3),Float16(3)) ≈ true_k33
        @test besselk(-3,3) ≈ true_k33
        true_k3m3 = -0.1221703757571835679 - 3.0151549516807985776im
        @test besselk(3,complex(-3)) ≈ true_k3m3
        @test besselk(-3,complex(-3)) ≈ true_k3m3
        # issue #6564
        @test besselk(1.0,0.0) == Inf
        @testset "Error throwing" begin
            @test_throws AmosException besselk(200,0.01)
            @test_throws DomainError besselk(3,-3)
            @test_throws MethodError besselk(1,big(1.0))
            @test_throws MethodError besselk(1,complex(big(1.0)))
            @test_throws MethodError besselkx(1,big(1.0))
            @test_throws MethodError besselkx(1,complex(big(1.0)))
        end
    end

    @testset "bessely" begin
        y33 = bessely(3,3.)
        @test bessely(3,3) == y33
        @test bessely(3.,3.) == y33
        @test bessely(3,Float32(3.)) ≈ y33
        @test bessely(-3,3) ≈ -y33
        @test y33 ≈ -0.53854161610503161800
        @test bessely(3,complex(-3)) ≈ 0.53854161610503161800 - 0.61812544451050328724im
        @testset "Error throwing" begin
            @test_throws AmosException bessely(200.5,0.1)
            @test_throws DomainError bessely(3,-3)
            @test_throws DomainError bessely(0.4,-1.0)
            @test_throws DomainError bessely(0.4,Float32(-1.0))
            @test_throws DomainError bessely(1,Float32(-1.0))
            @test_throws DomainError bessely(0.4,BigFloat(-1.0))
            @test_throws DomainError bessely(1,BigFloat(-1.0))
            @test_throws DomainError bessely(Cint(3),Float32(-3.))
            @test_throws DomainError bessely(Cint(3),Float64(-3.))

            @test_throws MethodError bessely(1.2,big(1.0))
            @test_throws MethodError bessely(1,complex(big(1.0)))
            @test_throws MethodError besselyx(1,big(1.0))
            @test_throws MethodError besselyx(1,complex(big(1.0)))
        end
    end

    @testset "besselhx" begin
        for elty in [Complex{Float16},Complex{Float32},Complex{Float64}]
            z = convert(elty, 1.0 + 1.9im)
            @test besselhx(1.0, 1, z) ≈ convert(elty,-0.5949634147786144 - 0.18451272807835967im)
            @test besselhx(Float32(1.0), 1, z) ≈ convert(elty,-0.5949634147786144 - 0.18451272807835967im)
        end
        @testset "Error throwing" begin
            @test_throws MethodError besselh(1,1,big(1.0))
            @test_throws MethodError besselh(1,1,complex(big(1.0)))
            @test_throws MethodError besselhx(1,1,big(1.0))
            @test_throws MethodError besselhx(1,1,complex(big(1.0)))
        end
    end
    @testset "scaled bessel[ijky] and hankelh[12]" begin
        for x in (1.0, 0.0, -1.0), y in (1.0, 0.0, -1.0), nu in (1.0, 0.0, -1.0)
            z = Complex{Float64}(x + y * im)
            z == zero(z) || @test hankelh1x(nu, z) ≈ hankelh1(nu, z) * exp(-z * im)
            z == zero(z) || @test hankelh2x(nu, z) ≈ hankelh2(nu, z) * exp(z * im)
            (nu < 0 && z == zero(z)) || @test besselix(nu, z) ≈ besseli(nu, z) * exp(-abs(real(z)))
            (nu < 0 && z == zero(z)) || @test besseljx(nu, z) ≈ besselj(nu, z) * exp(-abs(imag(z)))
            z == zero(z) || @test besselkx(nu, z) ≈ besselk(nu, z) * exp(z)
            z == zero(z) || @test besselyx(nu, z) ≈ bessely(nu, z) * exp(-abs(imag(z)))
        end
        @test besselkx(1, 0) == Inf
        for i = [-5 -3 -1 1 3 5]
            @test besseljx(i,0) == 0
            @test besselix(i,0) == 0
            @test besseljx(i,Float32(0)) == 0
            @test besselix(i,Float32(0)) == 0
            @test besseljx(i,Complex{Float32}(0)) == 0
            @test besselix(i,Complex{Float32}(0)) == 0
            @test besseljx(i,Float16(0)) == 0
            @test besselix(i,Float16(0)) == 0
            @test besseljx(i,Complex{Float16}(0)) == 0
            @test besselix(i,Complex{Float16}(0)) == 0
        end
        @testset "Error throwing" begin
            @test_throws AmosException hankelh1x(1, 0)
            @test_throws AmosException hankelh2x(1, 0)
            @test_throws AmosException besselix(-1.01, 0)
            @test_throws AmosException besseljx(-1.01, 0)
            @test_throws AmosException besselyx(1, 0)
            @test_throws DomainError besselix(0.4,-1.0)
            @test_throws DomainError besseljx(0.4, -1.0)
            @test_throws DomainError besselkx(0.4,-1.0)
            @test_throws DomainError besselyx(0.4,-1.0)
        end
    end
    @testset "issue #6653" begin
        @testset "$f" for f in (besselj,bessely,besseli,besselk,hankelh1,hankelh2)
            @test f(0,1) ≈ f(0,Complex{Float64}(1))
            @test f(0,1) ≈ f(0,Complex{Float32}(1))
            @test f(0,1) ≈ f(0,Complex{Float16}(1))
        end
    end
end

@testset "gamma and friends" begin
    @testset "digamma" begin
        @testset "$elty" for elty in (Float32, Float64)
            @test digamma(convert(elty, 9)) ≈ convert(elty, 2.140641477955609996536345)
            @test digamma(convert(elty, 2.5)) ≈ convert(elty, 0.7031566406452431872257)
            @test digamma(convert(elty, 0.1)) ≈ convert(elty, -10.42375494041107679516822)
            @test digamma(convert(elty, 7e-4)) ≈ convert(elty, -1429.147493371120205005198)
            @test digamma(convert(elty, 7e-5)) ≈ convert(elty, -14286.29138623969227538398)
            @test digamma(convert(elty, 7e-6)) ≈ convert(elty, -142857.7200612932791081972)
            @test digamma(convert(elty, 2e-6)) ≈ convert(elty, -500000.5772123750382073831)
            @test digamma(convert(elty, 1e-6)) ≈ convert(elty, -1000000.577214019968668068)
            @test digamma(convert(elty, 7e-7)) ≈ convert(elty, -1428572.005785942019703646)
            @test digamma(convert(elty, -0.5)) ≈ convert(elty, .03648997397857652055902367)
            @test digamma(convert(elty, -1.1)) ≈ convert(elty,  10.15416395914385769902271)

            @test digamma(convert(elty, 0.1)) ≈ convert(elty, -10.42375494041108)
            @test digamma(convert(elty, 1/2)) ≈ convert(elty, -γ - log(4))
            @test digamma(convert(elty, 1)) ≈ convert(elty, -γ)
            @test digamma(convert(elty, 2)) ≈ convert(elty, 1 - γ)
            @test digamma(convert(elty, 3)) ≈ convert(elty, 3/2 - γ)
            @test digamma(convert(elty, 4)) ≈ convert(elty, 11/6 - γ)
            @test digamma(convert(elty, 5)) ≈ convert(elty, 25/12 - γ)
            @test digamma(convert(elty, 10)) ≈ convert(elty, 7129/2520 - γ)
        end
    end

    @testset "trigamma" begin
        @testset "$elty" for elty in (Float32, Float64)
            @test trigamma(convert(elty, 0.1)) ≈ convert(elty, 101.433299150792758817)
            @test trigamma(convert(elty, 0.1)) ≈ convert(elty, 101.433299150792758817)
            @test trigamma(convert(elty, 1/2)) ≈ convert(elty, π^2/2)
            @test trigamma(convert(elty, 1)) ≈ convert(elty, π^2/6)
            @test trigamma(convert(elty, 2)) ≈ convert(elty, π^2/6 - 1)
            @test trigamma(convert(elty, 3)) ≈ convert(elty, π^2/6 - 5/4)
            @test trigamma(convert(elty, 4)) ≈ convert(elty, π^2/6 - 49/36)
            @test trigamma(convert(elty, 5)) ≈ convert(elty, π^2/6 - 205/144)
            @test trigamma(convert(elty, 10)) ≈ convert(elty, π^2/6 - 9778141/6350400)
        end
    end

    @testset "invdigamma" begin
        @testset "$elty" for elty in (Float32, Float64)
            for val in [0.001, 0.01, 0.1, 1.0, 10.0]
                @test abs(invdigamma(digamma(convert(elty, val))) - convert(elty, val)) < 1e-8
            end
        end
        @test abs(invdigamma(2)) == abs(invdigamma(2.))
    end

    @testset "polygamma" begin
        @test polygamma(20, 7.) ≈ -4.644616027240543262561198814998587152547
        @test polygamma(20, Float16(7.)) ≈ -4.644616027240543262561198814998587152547
    end

    @testset "eta" begin
        @test eta(1) ≈ log(2)
        @test eta(2) ≈ pi^2/12
        @test eta(Float32(2)) ≈ eta(2)
        @test eta(Complex{Float32}(2)) ≈ eta(2)
    end
end

@testset "zeta" begin
    @test zeta(0) ≈ -0.5
    @test zeta(2) ≈ pi^2/6
    @test zeta(Complex{Float32}(2)) ≈ zeta(2)
    @test zeta(4) ≈ pi^4/90
    @test zeta(1,Float16(2.)) ≈ zeta(1,2.)
    @test zeta(1.,Float16(2.)) ≈ zeta(1,2.)
    @test zeta(Float16(1.),Float16(2.)) ≈ zeta(1,2.)
    @test isnan(zeta(NaN))
    @test isnan(zeta(1.0e0))
    @test isnan(zeta(1.0f0))
    @test isnan(zeta(complex(0,Inf)))
    @test isnan(zeta(complex(-Inf,0)))
end

#(compared to Wolfram Alpha)
@testset "digamma, trigamma, polygamma & zeta" begin
    for x in -10.2:0.3456:50
        @test 1e-12 > relerr(digamma(x+0im), digamma(x))
    end
    @test digamma(7+0im) ≅ 1.872784335098467139393487909917597568957840664060076401194232
    @test digamma(7im) ≅ 1.94761433458434866917623737015561385331974500663251349960124 + 1.642224898223468048051567761191050945700191089100087841536im
    @test digamma(-3.2+0.1im) ≅ 4.65022505497781398615943030397508454861261537905047116427511+2.32676364843128349629415011622322040021960602904363963042380im
    @test trigamma(8+0im) ≅ 0.133137014694031425134546685920401606452509991909746283540546
    @test trigamma(8im) ≅ -0.0078125000000000000029194973110119898029284994355721719150 - 0.12467345030312762782439017882063360876391046513966063947im
    @test trigamma(-3.2+0.1im) ≅ 15.2073506449733631753218003030676132587307964766963426965699+15.7081038855113567966903832015076316497656334265029416039199im
    @test polygamma(2, 8.1+0im) ≅ -0.01723882695611191078960494454602091934457319791968308929600
    @test polygamma(30, 8.1+2im) ≅ -2722.8895150799704384107961215752996280795801958784600407589+6935.8508929338093162407666304759101854270641674671634631058im
    @test polygamma(3, 2.1+1im) ≅ 0.00083328137020421819513475400319288216246978855356531898998-0.27776110819632285785222411186352713789967528250214937861im
    @test 1e-11 > relerr(polygamma(3, -4.2 + 2im),-0.0037752884324358856340054736472407163991189965406070325067-0.018937868838708874282432870292420046797798431078848805822im)
    @test polygamma(13, 5.2 - 2im) ≅ 0.08087519202975913804697004241042171828113370070289754772448-0.2300264043021038366901951197725318713469156789541415899307im
    @test 1e-11 > relerr(polygamma(123, -47.2 + 0im), 5.7111648667225422758966364116222590509254011308116701029e291)
    @test zeta(4.1+0.3im, -3.2+0.1im) ≅ -281.34474134962502296077659347175501181994490498591796647 + 286.55601240093672668066037366170168712249413003222992205im
    @test zeta(4.1+0.3im, 3.2+0.1im) ≅ 0.0121197525131633219465301571139288562254218365173899270675-0.00687228692565614267981577154948499247518236888933925740902im
    @test zeta(4.1, 3.2+0.1im) ≅ 0.0137637451187986846516125754047084829556100290057521276517-0.00152194599531628234517456529686769063828217532350810111482im
    @test 1e-12 > relerrc(zeta(1.0001, -4.5e2+3.2im), 10003.765660925877260544923069342257387254716966134385170 - 0.31956240712464746491659767831985629577542514145649468090im)
    @test zeta(3.1,-4.2) ≅ zeta(3.1,-4.2+0im) ≅ 149.7591329008219102939352965761913107060718455168339040295
    @test 1e-15 > relerrc(zeta(3.1+0im,-4.2), zeta(3.1,-4.2+0im))
    @test zeta(3.1,4.2) ≅ 0.029938344862645948405021260567725078588893266227472565010234
    @test zeta(27, 3.1) ≅ 5.413318813037879056337862215066960774064332961282599376e-14
    @test zeta(27, 2) ≅ 7.4507117898354294919810041706041194547190318825658299932e-9
    @test 1e-12 > relerr(zeta(27, -105.3), 1.3113726525492708826840989036205762823329453315093955e14)
    @test polygamma(4, -3.1+Inf*im) == polygamma(4, 3.1+Inf*im) == 0
    @test polygamma(4, -0.0) == Inf == -polygamma(4, +0.0)
    @test zeta(4, +0.0) == zeta(4, -0.0) ≅ pi^4 / 90
    @test zeta(5, +0.0) == zeta(5, -0.0) ≅ 1.036927755143369926331365486457034168057080919501912811974
    @test zeta(Inf, 1.) == 1
    @test zeta(Inf, 2.) == 0
    @test isnan(zeta(NaN, 1.))
    @test isa([digamma(x) for x in [1.0]], Vector{Float64})
    @test isa([trigamma(x) for x in [1.0]], Vector{Float64})
    @test isa([polygamma(3,x) for x in [1.0]], Vector{Float64})
    @test zeta(2 + 1im, -1.1) ≅ zeta(2 + 1im, -1.1+0im) ≅ -64.580137707692178058665068045847533319237536295165484548 + 73.992688148809018073371913557697318846844796582012921247im
    @test polygamma(3,5) ≈ polygamma(3,5.)

    @test zeta(-3.0, 7.0) ≅ -52919/120
    @test zeta(-3.0, -7.0) ≅ 94081/120
    @test zeta(-3.1, 7.2) ≅ -587.457736596403704429103489502662574345388906240906317350719
    @test zeta(-3.1, -7.2) ≅ 1042.167459863862249173444363794330893294733001752715542569576
    @test zeta(-3.1, 7.0) ≅ -518.431785723446831868686653718848680989961581500352503093748
    @test zeta(-3.1, -7.0) ≅ 935.1284612957581823462429983411337864448020149908884596048161
    @test zeta(-3.1-0.1im, 7.2) ≅ -579.29752287650299181119859268736614017824853865655709516268 - 96.551907752211554484321948972741033127192063648337407683877im
    @test zeta(-3.1-0.1im, -7.2) ≅ 1025.17607931184231774568797674684390615895201417983173984531 + 185.732454778663400767583204948796029540252923367115805842138im
    @test zeta(-3.1-0.1im, 7.2 + 0.1im) ≅ -571.66133526455569807299410569274606007165253039948889085762 - 131.86744836357808604785415199791875369679879576524477540653im
    @test zeta(-3.1-0.1im, -7.2 + 0.1im) ≅ 1035.35760409421020754141207226034191979220047873089445768189 + 130.905870774271320475424492384335798304480814695778053731045im
    @test zeta(-3.1-0.1im, -7.0 + 0.1im) ≅ 929.546530292101383210555114424269079830017210969572819344670 + 113.646687807533854478778193456684618838875194573742062527301im
    @test zeta(-3.1, 7.2 + 0.1im) ≅ -586.61801005507638387063781112254388285799318636946559637115 - 36.148831292706044180986261734913443701649622026758378669700im
    @test zeta(-3.1, -7.2 + 0.1im) ≅ 1041.04241628770682295952302478199641560576378326778432301623 - 55.7154858634145071137760301929537184886497572057171143541058im
    @test zeta(-13.4, 4.1) ≅ -3.860040842156185186414774125656116135638705768861917e6
    @test zeta(3.2, -4) ≅ 2.317164896026427640718298719837102378116771112128525719078
    @test zeta(3.2, 0) ≅ 1.166773370984467020452550350896512026772734054324169010977
    @test zeta(-3.2+0.1im, 0.0) ≅ zeta(-3.2+0.1im, 0.0+0im) ≅ 0.0070547946138977701155565365569392198424378109226519905493 + 0.00076891821792430587745535285452496914239014050562476729610im
    @test zeta(-3.2, 0.0) ≅ zeta(-3.2, 0.0+0im) ≅ 0.007011972077091051091698102914884052994997144629191121056378

    @test 1e-14 > relerr(eta(1+1e-9), 0.693147180719814213126976796937244130533478392539154928250926)
    @test 1e-14 > relerr(eta(1+5e-3), 0.693945708117842473436705502427198307157819636785324430166786)
    @test 1e-13 > relerr(eta(1+7.1e-3), 0.694280602623782381522315484518617968911346216413679911124758)
    @test 1e-13 > relerr(eta(1+8.1e-3), 0.694439974969407464789106040237272613286958025383030083792151)
    @test 1e-13 > relerr(eta(1 - 2.1e-3 + 2e-3 * im), 0.69281144248566007063525513903467244218447562492555491581+0.00032001240133205689782368277733081683574922990400416791019im)
    @test 1e-13 > relerr(eta(1 + 5e-3 + 5e-3 * im), 0.69394652468453741050544512825906295778565788963009705146+0.00079771059614865948716292388790427833787298296229354721960im)
    @test 1e-12 > relerrc(zeta(1e-3+1e-3im), -0.5009189365276307665899456585255302329444338284981610162-0.0009209468912269622649423786878087494828441941303691216750im)
    @test 1e-13 > relerrc(zeta(1e-4 + 2e-4im), -0.5000918637469642920007659467492165281457662206388959645-0.0001838278317660822408234942825686513084009527096442173056im)

    # Issue #7169:
    @test 1e-13  > relerrc(zeta(0 + 99.69im), 4.67192766128949471267133846066040655597942700322077493021802+3.89448062985266025394674304029984849370377607524207984092848im)
    @test 1e-12 > relerrc(zeta(3 + 99.69im), 1.09996958148566565003471336713642736202442134876588828500-0.00948220959478852115901654819402390826992494044787958181148im)
    @test 1e-13  > relerrc(zeta(-3 + 99.69im), 10332.6267578711852982128675093428012860119184786399673520976+13212.8641740351391796168658602382583730208014957452167440726im)
    @test 1e-13 > relerrc(zeta(2 + 99.69im, 1.3), 0.41617652544777996034143623540420694985469543821307918291931-0.74199610821536326325073784018327392143031681111201859489991im)

    # issue #128
    @test 1e-13 > relerrc(zeta(.4 + 453.0im), 5.595631794716693 - 4.994584420588448im)
    @test 1e-10 > relerrc(zeta(.4 + 4053.0im), -0.1248993234383550+0.9195498409364987im)
    @test 1e-13 > relerrc(zeta(.4 + 12.01im), 1.0233184799021265846512208845-0.8008078492939259287905322251im)
    @test zeta(.4 + 12.01im) == conj(zeta(.4 - 12.01im))
end

@testset "vectorization of 2-arg functions" begin
    binary_math_functions = [
        besselh, hankelh1, hankelh2, hankelh1x, hankelh2x,
        besseli, besselix, besselj, besseljx, besselk, besselkx, bessely, besselyx,
        polygamma, zeta
    ]
    @testset "$f" for f in binary_math_functions
        x = y = 2
        v = [f(x,y)]
        @test f.([x],y) == v
        @test f.(x,[y]) == v
        @test f.([x],[y]) == v
    end
end

@testset "MPFR" begin
    @testset "bessel functions" begin
        setprecision(53) do
            @test besselj(4, BigFloat(2)) ≈ besselj(4, 2.)
            @test besselj0(BigFloat(2)) ≈ besselj0(2.)
            @test besselj1(BigFloat(2)) ≈ besselj1(2.)
            @test bessely(4, BigFloat(2)) ≈ bessely(4, 2.)
            @test bessely0(BigFloat(2)) ≈ bessely0(2.)
            @test bessely1(BigFloat(2)) ≈ bessely1(2.)
        end
    end

    let err(z, x) = abs(z - x) / abs(x)
        @test 1e-60 > err(eta(parse(BigFloat,"1.005")), parse(BigFloat,"0.693945708117842473436705502427198307157819636785324430166786"))
        @test 1e-60 > err(exp(eta(big(1.0))), 2.0)
    end

    let a = parse(BigInt, "315135")
        @test typeof(erf(a)) == BigFloat
        @test typeof(erfc(a)) == BigFloat
    end

    # issue #101
    for i in 0:5
        @test gamma(big(i)) == gamma(i)
    end
end

@testset "Base Julia issue #17474" begin
    @test f64(complex(1f0,1f0)) === complex(1.0, 1.0)
    @test f64(1f0) === 1.0

    @test typeof(eta(big"2")) == BigFloat
    @test typeof(zeta(big"2")) == BigFloat
    @test typeof(digamma(big"2")) == BigFloat

    @test_throws MethodError trigamma(big"2")
    @test_throws MethodError trigamma(big"2.0")
    @test_throws MethodError invdigamma(big"2")
    @test_throws MethodError invdigamma(big"2.0")

    @test_throws MethodError eta(Complex(big"2"))
    @test_throws MethodError eta(Complex(big"2.0"))
    @test_throws MethodError zeta(Complex(big"2"))
    @test_throws MethodError zeta(Complex(big"2.0"))
    @test_throws MethodError zeta(1.0,big"2")
    @test_throws MethodError zeta(1.0,big"2.0")
    @test_throws MethodError zeta(big"1.0",2.0)
    @test_throws MethodError zeta(big"1",2.0)


    @test typeof(polygamma(3, 0x2)) == Float64
    @test typeof(polygamma(big"3", 2f0)) == Float32
    @test typeof(zeta(1, 2.0)) == Float64
    @test typeof(zeta(1, 2f0)) == Float64 # BitIntegers result in Float64 returns
    @test typeof(zeta(2f0, complex(2f0,0f0))) == Complex{Float32}
    @test typeof(zeta(complex(1,1), 2f0)) == Complex{Float64}
    @test typeof(zeta(complex(1), 2.0)) == Complex{Float64}
end

@test sprint(showerror, AmosException(1)) == "AmosException with id 1: input error."
# Used to check method existence below
struct NotAFloat <: AbstractFloat
end

@testset "gamma and friends" begin
    @testset "gamma, loggamma, logabsgamma (complex argument)" begin
        if Base.Math.libm == "libopenlibm"
            @test gamma.(Float64[1:25;]) == gamma.(1:25)
        else
            @test gamma.(Float64[1:25;]) ≈ gamma.(1:25)
        end
        for elty in (Float32, Float64)
            @test gamma(convert(elty,1/2)) ≈ convert(elty,sqrt(π))
            @test gamma(convert(elty,-1/2)) ≈ convert(elty,-2sqrt(π))
            @test logabsgamma(convert(elty,-1/2))[1] ≈ convert(elty,log(abs(gamma(-1/2))))
        end
        @test loggamma(1.4+3.7im) ≈ -3.7094025330996841898 + 2.4568090502768651184im
        @test loggamma(1.4+3.7im) ≈ log(gamma(1.4+3.7im))
        @test loggamma(-4.2+0im) ≈ logabsgamma(-4.2)[1] - 5pi*im
        @test SpecialFunctions.factorial(3.0) == gamma(4.0) == factorial(3)
        for x in (3.2, 2+1im, 3//2, 3.2+0.1im)
            @test SpecialFunctions.factorial(x) == gamma(1+x)
        end
        @test logfactorial(0) == logfactorial(1) == 0
        @test logfactorial(2) == loggamma(3)
        # Ensure that the domain of logfactorial matches that of factorial (issue #21318)
        @test_throws DomainError logfactorial(-3)
        @test_throws DomainError loggamma(-4.2)
        @test_throws MethodError logfactorial(1.0)
    end

    # loggamma & logabsgamma test cases (from Wolfram Alpha)
    @test loggamma(-300im) ≅ -473.17185074259241355733179182866544204963885920016823743 - 1410.3490664555822107569308046418321236643870840962522425im
    @test loggamma(3.099) ≅ loggamma(3.099+0im) ≅ 0.786413746900558058720665860178923603134125854451168869796
    @test loggamma(1.15) ≅ loggamma(1.15+0im) ≅ -0.06930620867104688224241731415650307100375642207340564554
    @test logabsgamma(0.89)[1] ≅ loggamma(0.89+0im) ≅ 0.074022173958081423702265889979810658434235008344573396963
    @test loggamma(0.91) ≅ loggamma(0.91+0im) ≅ 0.058922567623832379298241751183907077883592982094770449167
    @test loggamma(0.01) ≅ loggamma(0.01+0im) ≅ 4.599479878042021722513945411008748087261001413385289652419
    @test loggamma(-3.4-0.1im) ≅ -1.1733353322064779481049088558918957440847715003659143454 + 12.331465501247826842875586104415980094316268974671819281im
    @test loggamma(-13.4-0.1im) ≅ -22.457344044212827625152500315875095825738672314550695161 + 43.620560075982291551250251193743725687019009911713182478im
    @test loggamma(-13.4+0.0im) ≅ conj(loggamma(-13.4-0.0im)) ≅ -22.404285036964892794140985332811433245813398559439824988 - 43.982297150257105338477007365913040378760371591251481493im
    @test loggamma(-13.4+8im) ≅ -44.705388949497032519400131077242200763386790107166126534 - 22.208139404160647265446701539526205774669649081807864194im
    @test logabsgamma(1+exp2(-20))[1] ≅ loggamma(1+exp2(-20)+0im) ≅ -5.504750066148866790922434423491111098144565651836914e-7
    @test loggamma(1+exp2(-20)+exp2(-19)*im) ≅ -5.5047799872835333673947171235997541985495018556426e-7 - 1.1009485171695646421931605642091915847546979851020e-6im
    @test loggamma(-300+2im) ≅ -1419.3444991797240659656205813341478289311980525970715668 - 932.63768120761873747896802932133229201676713644684614785im
    @test loggamma(300+2im) ≅ 1409.19538972991765122115558155209493891138852121159064304 + 11.4042446282102624499071633666567192538600478241492492652im
    @test loggamma(1-6im) ≅ -7.6099596929506794519956058191621517065972094186427056304 - 5.5220531255147242228831899544009162055434670861483084103im
    @test loggamma(1-8im) ≅ -10.607711310314582247944321662794330955531402815576140186 - 9.4105083803116077524365029286332222345505790217656796587im
    @test loggamma(1+6.5im) ≅ conj(loggamma(1-6.5im)) ≅ -8.3553365025113595689887497963634069303427790125048113307 + 6.4392816159759833948112929018407660263228036491479825744im
    @test loggamma(1+1im) ≅ conj(loggamma(1-1im)) ≅ -0.6509231993018563388852168315039476650655087571397225919 - 0.3016403204675331978875316577968965406598997739437652369im
    @test loggamma(-pi*1e7 + 6im) ≅ -5.10911758892505772903279926621085326635236850347591e8 - 9.86959420047365966439199219724905597399295814979993e7im
    @test loggamma(-pi*1e7 + 8im) ≅ -5.10911765175690634449032797392631749405282045412624e8 - 9.86959074790854911974415722927761900209557190058925e7im
    @test loggamma(-pi*1e14 + 6im) ≅ -1.0172766411995621854526383224252727000270225301426e16 - 9.8696044010873714715264929863618267642124589569347e14im
    @test loggamma(-pi*1e14 + 8im) ≅ -1.0172766411995628137711690403794640541491261237341e16 - 9.8696044010867038531027376655349878694397362250037e14im
    @test loggamma(2.05 + 0.03im) ≅ conj(loggamma(2.05 - 0.03im)) ≅ 0.02165570938532611215664861849215838847758074239924127515 + 0.01363779084533034509857648574107935425251657080676603919im
    @test loggamma(2+exp2(-20)+exp2(-19)*im) ≅ 4.03197681916768997727833554471414212058404726357753e-7 + 8.06398296652953575754782349984315518297283664869951e-7im

    @testset "loggamma for non-finite arguments" begin
        @test loggamma(Inf + 0im) === Inf + 0im
        @test loggamma(Inf - 0.0im) === Inf - 0.0im
        @test loggamma(Inf + 1im) === Inf + Inf*im
        @test loggamma(Inf - 1im) === Inf - Inf*im
        @test loggamma(-Inf + 0.0im) === -Inf - Inf*im
        @test loggamma(-Inf - 0.0im) === -Inf + Inf*im
        @test loggamma(Inf*im) === -Inf + Inf*im
        @test loggamma(-Inf*im) === -Inf - Inf*im
        @test loggamma(Inf + Inf*im) === loggamma(NaN + 0im) === loggamma(NaN*im) === NaN + NaN*im
    end
    @testset "Other float types" begin
        let x = one(Float16)
            @test gamma(x) ≈ one(Float16)
            @test gamma(x) isa Float16
            @test loggamma(x) ≈ zero(Float16)
            @test loggamma(x) isa Float16
        end
        @test_throws MethodError gamma(NotAFloat())
        @test_throws MethodError logabsgamma(NotAFloat())
        @test_throws MethodError loggamma(NotAFloat())
    end
end

@testset "beta, lbeta" begin
    @test beta(3/2,7/2) ≈ 5π/128
    @test beta(3,5) ≈ 1/105
    @test logbeta(5,4) ≈ log(beta(5,4))
    @test beta(5,4) ≈ beta(4,5)
    @test beta(-1/2, 3) ≈ beta(-1/2 + 0im, 3 + 0im) ≈ -16/3
    @test logabsbeta(-1/2, 3)[1] ≈ log(16/3)
    @test beta(Float32(5),Float32(4)) == beta(Float32(4),Float32(5))
    @test beta(3,5) ≈ beta(3+0im,5+0im)
    @test(beta(3.2+0.1im,5.3+0.3im) ≈ exp(logbeta(3.2+0.1im,5.3+0.3im)) ≈
          0.00634645247782269506319336871208405439180447035257028310080 -
          0.00169495384841964531409376316336552555952269360134349446910im)

    @test beta(big(1.0),big(1.2)) ≈ beta(1.0,1.2) rtol=4*eps()
end

@testset "logabsbinomial" begin
    @test logabsbinomial(10, -1) == (-Inf, 0.0)
    @test logabsbinomial(10, 11) == (-Inf, 0.0)
    @test logabsbinomial(10,  0) == ( 0.0, 1.0)
    @test logabsbinomial(10, 10) == ( 0.0, 1.0)

    @test logabsbinomial(10,  1)[1]   ≈ log(10)
    @test logabsbinomial(10,  1)[2]   == 1.0
    @test logabsbinomial(-6, 10)[1]   ≈ log(binomial(-6, 10))
    @test logabsbinomial(-6, 10)[2]   == 1.0
    @test logabsbinomial(-6, 11)[1]   ≈ log(abs(binomial(-6, 11)))
    @test logabsbinomial(-6, 11)[2]   == -1.0
    @test first.(logabsbinomial.(200, 0:200)) ≈ log.(binomial.(BigInt(200), (0:200)))
end

@testset "missing data" begin
    for f in (digamma, erf, erfc, erfcinv, erfcx, erfi, erfinv, eta, gamma,
              invdigamma, logfactorial, trigamma)
        @test f(missing) === missing
    end
    @test beta(1.0, missing) === missing
    @test beta(missing, 1.0) === missing
    @test beta(missing, missing) === missing
    @test polygamma(4, missing) === missing
end
