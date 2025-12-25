# "Namespace: ICU4N.Text"
type
  OpenStringBuilderTest = ref object
    LargeUnicodeString: string = "⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛⽄⿚⼃⾮⾵⿞⼒⼱⾠⽚⽕⽆⾭⾕⼇⼂⽖⽋⽲⿘⿄⽁⼄⼽⾸⼉⽤⾲⼡⿛⼱⼈⽥⾰⽬⼤⿃⽞⽪⽗⼟⾃⼪⾔⾏⼼⿛⼩⼘⼷⾪⼲⾛⾫⾊⼃⿕⾥⿕⾫⽹⽀⼐⾤⼩⽍⿀⿝⼩⿂⼞⿗⿁⼚⾹⽁⼖⽐⾎⽻⼍⼻⾚⿊⼰⿟⽌⾚⼥⽨⼯⼞⽩⾞⾽⾿⽳⽥⽫⽁⽛"

proc Ctor_Default_CanAppend*() =
    var vsb = OpenStringBuilder
Assert.AreEqual(0, vsb.Length)
vsb.Append('a')
Assert.AreEqual(1, vsb.Length)
Assert.AreEqual("a", vsb.ToString)
proc Ctor_InitialCapacity_CanAppend*() =
    var vsb = OpenStringBuilder(1)
Assert.AreEqual(0, vsb.Length)
vsb.Append('a')
Assert.AreEqual(1, vsb.Length)
Assert.AreEqual("a", vsb.ToString)
proc Append_Char_MatchesStringBuilder*() =
    var sb = StringBuilder
    var vsb = OpenStringBuilder
      var i: int = 1
      while i <= 100:
sb.Append(cast[char](i))
vsb.Append(cast[char](i))
++i
Assert.AreEqual(sb.Length, vsb.Length)
Assert.AreEqual(sb.ToString, vsb.ToString)
proc Append_String_MatchesStringBuilder*() =
    var sb = StringBuilder
    var vsb = OpenStringBuilder
      var i: int = 1
      while i <= 100:
          var s: string = i.ToString
sb.Append(s)
vsb.Append(s)
++i
Assert.AreEqual(sb.Length, vsb.Length)
Assert.AreEqual(sb.ToString, vsb.ToString)
proc Append_String_Large_MatchesStringBuilder*(initialLength: int, stringLength: int) =
    var sb = StringBuilder(initialLength)
    var vsb = OpenStringBuilder(initialLength)
    var s: string = string('a', stringLength)
sb.Append(s)
vsb.Append(s)
Assert.AreEqual(sb.Length, vsb.Length)
Assert.AreEqual(sb.ToString, vsb.ToString)
proc Append_CharInt_MatchesStringBuilder*() =
    var sb = StringBuilder
    var vsb = OpenStringBuilder
      var i: int = 1
      while i <= 100:
sb.Append(cast[char](i), i)
vsb.Append(cast[char](i), i)
++i
Assert.AreEqual(sb.Length, vsb.Length)
Assert.AreEqual(sb.ToString, vsb.ToString)
proc AppendSpan_DataAppendedCorrectly*() =
    var sb = StringBuilder
    var vsb = OpenStringBuilder
      var i: int = 1
      while i <= 1000:
          var s: string = i.ToString
sb.Append(s)
          var span: Span<char> = vsb.AppendSpan(s.Length)
Assert.AreEqual(sb.Length, vsb.Length)
s.AsSpan.CopyTo(span)
++i
Assert.AreEqual(sb.Length, vsb.Length)
Assert.AreEqual(sb.ToString, vsb.ToString)
proc Insert_IntCharInt_MatchesStringBuilder*() =
    var sb = StringBuilder
    var vsb = OpenStringBuilder
    var rand = Random(42)
      var i: int = 1
      while i <= 100:
          var index: int = rand.Next(sb.Length)
sb.Insert(index, string(cast[char](i), 1), i)
vsb.Insert(index, cast[char](i), i)
++i
Assert.AreEqual(sb.Length, vsb.Length)
Assert.AreEqual(sb.ToString, vsb.ToString)
proc AsSpan_ReturnsCorrectValue_DoesntClearBuilder*() =
    var sb = StringBuilder
    var vsb = OpenStringBuilder
      var i: int = 1
      while i <= 100:
          var s: string = i.ToString
sb.Append(s)
vsb.Append(s)
++i
    var resultString = vsb.AsSpan.ToString
Assert.AreEqual(sb.ToString, resultString)
Assert.AreNotEqual(0, sb.Length)
Assert.AreEqual(sb.Length, vsb.Length)
proc TryCopyTo_FailsWhenDestinationIsTooSmall_SucceedsWhenItsLargeEnough*() =
    var vsb = OpenStringBuilder
    var Text: string = "expected text"
vsb.Append(Text)
Assert.AreEqual(Text.Length, vsb.Length)
    var dst: Span<char> = seq[char]
Assert.False(vsb.TryCopyTo(dst,     var charsWritten: int))
Assert.AreEqual(0, charsWritten)
proc Indexer*() =
    var Text1: string = "foobar"
    var vsb = OpenStringBuilder
vsb.Append(Text1)
Assert.AreEqual('b', vsb[3])
    vsb[3] = 'c'
Assert.AreEqual('c', vsb[3])
proc EnsureCapacity_IfRequestedCapacityWins*() =
    var builder = OpenStringBuilder(32)
builder.EnsureCapacity(65)
Assert.AreEqual(128, builder.Capacity)
proc EnsureCapacity_IfBufferTimesTwoWins*() =
    var builder = OpenStringBuilder(32)
builder.EnsureCapacity(33)
Assert.AreEqual(64, builder.Capacity)
proc EnsureCapacity_NoAllocIfNotNeeded*() =
    var builder = OpenStringBuilder(64)
builder.EnsureCapacity(16)
Assert.AreEqual(64, builder.Capacity)
proc Remove*(value: string, startIndex: int, length: int, expected: string) =
    var builder = OpenStringBuilder(64)
builder.Append(value)
builder.Remove(startIndex, length)
Assert.AreEqual(expected, builder.ToString)
proc TestAppendCodePointBmp*() =
    var sb = OpenStringBuilder(16)
sb.Append("foo bar")
    var codePoint: int = 97
sb.AppendCodePoint(codePoint)
Assert.AreEqual("foo bara", sb.ToString)
proc TestAppendCodePointUnicode*() =
    var sb = OpenStringBuilder(16)
sb.Append("foo bar")
    var codePoint: int = 3594
sb.AppendCodePoint(codePoint)
Assert.AreEqual("foo barช", sb.ToString)
proc TestAppendCodePointUTF16Surrogates*() =
    var sb = OpenStringBuilder(16)
sb.Append("foo bar")
    var codePoint: int = 176129
sb.AppendCodePoint(codePoint)
Assert.AreEqual("foo bar𫀁", sb.ToString)
proc TestAppendCodePointTooHigh*() =
    var sb = OpenStringBuilder(16)
sb.Append("foo bar")
    var codePoint: int = J2N.Character.MaxCodePoint + 1
    try:
sb.AppendCodePoint(codePoint)
Assert.Fail("Expected ArgumentException")
    except ArgumentException:

proc TestAppendCodePointTooLow*() =
    var sb = OpenStringBuilder(16)
sb.Append("foo bar")
    var codePoint: int = J2N.Character.MinCodePoint - 1
    try:
sb.AppendCodePoint(codePoint)
Assert.Fail("Expected ArgumentException")
    except ArgumentException:

proc TestInsertCodePointBmp*() =
    var sb = OpenStringBuilder(16)
sb.Append("foo bar")
    var codePoint: int = 97
sb.InsertCodePoint(0, codePoint)
Assert.AreEqual("afoo bar", sb.ToString)
proc TestInsertCodePointUnicode*() =
    var sb = OpenStringBuilder(16)
sb.Append("foo bar")
    var codePoint: int = 3594
sb.InsertCodePoint(1, codePoint)
Assert.AreEqual("fชoo bar", sb.ToString)
proc TestInsertCodePointUTF16Surrogates*() =
    var sb = OpenStringBuilder(16)
sb.Append("foo bar")
    var codePoint: int = 176129
sb.InsertCodePoint(2, codePoint)
Assert.AreEqual("fo𫀁o bar", sb.ToString)
proc TestInsertCodePointTooHigh*() =
    var sb = OpenStringBuilder(16)
sb.Append("foo bar")
    var codePoint: int = J2N.Character.MaxCodePoint + 1
    try:
sb.InsertCodePoint(0, codePoint)
Assert.Fail("Expected ArgumentException")
    except ArgumentException:

proc TestInsertCodePointTooLow*() =
    var sb = OpenStringBuilder(16)
sb.Append("foo bar")
    var codePoint: int = J2N.Character.MinCodePoint - 1
    try:
sb.InsertCodePoint(0, codePoint)
Assert.Fail("Expected ArgumentException")
    except ArgumentException:

proc TestInsertCodePointIndexTooHigh*() =
    var sb = OpenStringBuilder(16)
sb.Append("foo bar")
    var codePoint: int = J2N.Character.MaxCodePoint
    try:
sb.InsertCodePoint(sb.Length + 1, codePoint)
Assert.Fail("Expected ArgumentOutOfRangeException")
    except ArgumentOutOfRangeException:

proc TestInsertCodePointIndexTooLow*() =
    var sb = OpenStringBuilder(16)
sb.Append("foo bar")
    var codePoint: int = J2N.Character.MinCodePoint
    try:
sb.InsertCodePoint(-1, codePoint)
Assert.Fail("Expected ArgumentOutOfRangeException")
    except ArgumentOutOfRangeException:

proc Test_Append_String*() =
    var sb = OpenStringBuilder(16)
sb.Append("ab")
Assert.AreEqual("ab", sb.ToString)
    sb.Length = 0
sb.Append("cd")
Assert.AreEqual("cd", sb.ToString)
    sb.Length = 0
sb.Append(cast[string](nil))
Assert.AreEqual("", sb.ToString)
proc Test_Append_String_Int32_Int32*() =
    var sb = OpenStringBuilder(16)
sb.Append("ab", 0, 2 - 0)
Assert.AreEqual("ab", sb.ToString)
    sb.Length = 0
sb.Append("cd", 0, 2 - 0)
Assert.AreEqual("cd", sb.ToString)
    sb.Length = 0
sb.Append("abcd", 0, 2 - 0)
Assert.AreEqual("ab", sb.ToString)
    sb.Length = 0
sb.Append("abcd", 2, 4 - 2)
Assert.AreEqual("cd", sb.ToString)
    sb.Length = 0
Assert.AreEqual("", sb.ToString)
proc Test_Append_CharArray*() =
    var sb = OpenStringBuilder(16)
sb.Append("ab".ToCharArray)
Assert.AreEqual("ab", sb.ToString)
    sb.Length = 0
sb.Append("cd".ToCharArray)
Assert.AreEqual("cd", sb.ToString)
    sb.Length = 0
sb.Append(cast[char[]](nil))
Assert.AreEqual("", sb.ToString)
proc Test_Append_CharArray_Int32_Int32*() =
    var sb = OpenStringBuilder(16)
sb.Append("ab".ToCharArray, 0, 2 - 0)
Assert.AreEqual("ab", sb.ToString)
    sb.Length = 0
sb.Append("cd".ToCharArray, 0, 2 - 0)
Assert.AreEqual("cd", sb.ToString)
    sb.Length = 0
sb.Append("abcd".ToCharArray, 0, 2 - 0)
Assert.AreEqual("ab", sb.ToString)
    sb.Length = 0
sb.Append("abcd".ToCharArray, 2, 4 - 2)
Assert.AreEqual("cd", sb.ToString)
    sb.Length = 0
Assert.AreEqual("", sb.ToString)
proc Test_Append_ICharSequence*() =
    var sb = OpenStringBuilder(16)
sb.Append("ab".AsCharSequence)
Assert.AreEqual("ab", sb.ToString)
    sb.Length = 0
sb.Append("cd".AsCharSequence)
Assert.AreEqual("cd", sb.ToString)
    sb.Length = 0
sb.Append(cast[ICharSequence](nil))
Assert.AreEqual("", sb.ToString)
proc Test_Append_ICharSequence_Int32_Int32*() =
    var sb = OpenStringBuilder(16)
sb.Append("ab".AsCharSequence, 0, 2 - 0)
Assert.AreEqual("ab", sb.ToString)
    sb.Length = 0
sb.Append("cd".AsCharSequence, 0, 2 - 0)
Assert.AreEqual("cd", sb.ToString)
    sb.Length = 0
sb.Append("abcd".AsCharSequence, 0, 2 - 0)
Assert.AreEqual("ab", sb.ToString)
    sb.Length = 0
sb.Append("abcd".AsCharSequence, 2, 4 - 2)
Assert.AreEqual("cd", sb.ToString)
    sb.Length = 0
Assert.AreEqual("", sb.ToString)
type
  MyCharSequence = ref object
    value: string

proc newMyCharSequence(value: string): MyCharSequence =
  self.value =   if value != nil:
value
  else:
      raise ArgumentNullException(nameof(value))

proc HasValue(): bool =
    return true
proc Length(): int =
    return value.Length
proc Subsequence*(startIndex: int, length: int): ICharSequence =
    return value.Substring(startIndex, length).AsCharSequence
proc Test_Append_ICharSequence_Custom*() =
    var sb = OpenStringBuilder(16)
sb.Append(MyCharSequence("ab"))
Assert.AreEqual("ab", sb.ToString)
    sb.Length = 0
sb.Append(MyCharSequence("cd"))
Assert.AreEqual("cd", sb.ToString)
    sb.Length = 0
sb.Append(cast[MyCharSequence](nil))
Assert.AreEqual("", sb.ToString)
proc Test_Append_ICharSequence_Int32_Int32_Custom*() =
    var sb = OpenStringBuilder(16)
sb.Append(MyCharSequence("ab"), 0, 2 - 0)
Assert.AreEqual("ab", sb.ToString)
    sb.Length = 0
sb.Append(MyCharSequence("cd"), 0, 2 - 0)
Assert.AreEqual("cd", sb.ToString)
    sb.Length = 0
sb.Append(MyCharSequence("abcd"), 0, 2 - 0)
Assert.AreEqual("ab", sb.ToString)
    sb.Length = 0
sb.Append(MyCharSequence("abcd"), 2, 4 - 2)
Assert.AreEqual("cd", sb.ToString)
    sb.Length = 0
Assert.AreEqual("", sb.ToString)
proc Test_Append_StringBuilder*() =
    var sb = OpenStringBuilder(16)
sb.Append(StringBuilder("ab"))
Assert.AreEqual("ab", sb.ToString)
    sb.Length = 0
sb.Append(StringBuilder("cd"))
Assert.AreEqual("cd", sb.ToString)
    sb.Length = 0
sb.Append(cast[StringBuilder](nil))
Assert.AreEqual("", sb.ToString)
proc Test_Append_StringBuilder_Int32_Int32*() =
    var sb = OpenStringBuilder(16)
sb.Append(StringBuilder("ab"), 0, 2 - 0)
Assert.AreEqual("ab", sb.ToString)
    sb.Length = 0
sb.Append(StringBuilder("cd"), 0, 2 - 0)
Assert.AreEqual("cd", sb.ToString)
    sb.Length = 0
sb.Append(StringBuilder("abcd"), 0, 2 - 0)
Assert.AreEqual("ab", sb.ToString)
    sb.Length = 0
sb.Append(StringBuilder("abcd"), 2, 4 - 2)
Assert.AreEqual("cd", sb.ToString)
    sb.Length = 0
Assert.AreEqual("", sb.ToString)
proc reverseTest(org: string, rev: string, back: string) =
    var sb = OpenStringBuilder(32)
sb.Append(org)
sb.Reverse
    var reversed: string = sb.ToString
Assert.AreEqual(rev, reversed)
    sb.Length = 0
sb.Append(reversed)
sb.Reverse
    reversed = sb.ToString
Assert.AreEqual(back, reversed)
    sb.Length = 0
sb.Append(org)
    var copy: string = sb.ToString
Assert.AreEqual(org, copy)
sb.Reverse
    reversed = sb.ToString
Assert.AreEqual(rev, reversed)
    sb.Length = 0
sb.Append(reversed)
    copy = sb.ToString
Assert.AreEqual(rev, copy)
sb.Reverse
    reversed = sb.ToString
Assert.AreEqual(back, reversed)
proc Test_Replace_String*() =
    var fixture: string = "0000"
    var sb: OpenStringBuilder = OpenStringBuilder
sb.Append(fixture)
sb.Replace(1, 3 - 1, "11")
Assert.AreEqual("0110", sb.AsSpan.ToString)
Assert.AreEqual(4, sb.Length)
    sb.Length = 0
sb.Append(fixture)
sb.Replace(1, 2 - 1, "11")
Assert.AreEqual("01100", sb.AsSpan.ToString)
Assert.AreEqual(5, sb.Length)
    sb.Length = 0
sb.Append(fixture)
sb.Replace(4, 5 - 4, "11")
Assert.AreEqual("000011", sb.AsSpan.ToString)
Assert.AreEqual(6, sb.Length)
    sb.Length = 0
sb.Append(fixture)
sb.Replace(4, 6 - 4, "11")
Assert.AreEqual("000011", sb.AsSpan.ToString)
Assert.AreEqual(6, sb.Length)
    var buffer: OpenStringBuilder = OpenStringBuilder
buffer.Append("1234567")
buffer.Replace(2, 6 - 2, "XXX")
Assert.AreEqual("12XXX7", buffer.ToString)
proc Test_Replace_ReadOnlySpan*() =
    var fixture: string = "0000"
    var sb: OpenStringBuilder = OpenStringBuilder
sb.Append(fixture)
sb.Replace(1, 3 - 1, "11".AsSpan)
Assert.AreEqual("0110", sb.AsSpan.ToString)
Assert.AreEqual(4, sb.Length)
    sb.Length = 0
sb.Append(fixture)
sb.Replace(1, 2 - 1, "11".AsSpan)
Assert.AreEqual("01100", sb.AsSpan.ToString)
Assert.AreEqual(5, sb.Length)
    sb.Length = 0
sb.Append(fixture)
sb.Replace(4, 5 - 4, "11".AsSpan)
Assert.AreEqual("000011", sb.AsSpan.ToString)
Assert.AreEqual(6, sb.Length)
    sb.Length = 0
sb.Append(fixture)
sb.Replace(4, 6 - 4, "11".AsSpan)
Assert.AreEqual("000011", sb.AsSpan.ToString)
Assert.AreEqual(6, sb.Length)
    var buffer: OpenStringBuilder = OpenStringBuilder
buffer.Append("1234567")
buffer.Replace(2, 6 - 2, "XXX".AsSpan)
Assert.AreEqual("12XXX7", buffer.AsSpan.ToString)
proc Test_DeleteII*() =
    var fixture: string = "0123456789"
    var sb = OpenStringBuilder(32)
sb.Append(fixture)
sb.Delete(0, 0 - 0)
Assert.AreEqual(fixture, sb.ToString)
sb.Delete(5, 5 - 5)
Assert.AreEqual(fixture, sb.ToString)
sb.Delete(0, 1 - 0)
Assert.AreEqual("123456789", sb.ToString)
Assert.AreEqual(9, sb.Length)
sb.Delete(0, sb.Length - 0)
Assert.AreEqual("", sb.ToString)
Assert.AreEqual(0, sb.Length)
    sb.Length = 0
sb.Append(fixture)
sb.Delete(0, 11 - 0)
Assert.AreEqual("", sb.ToString)
Assert.AreEqual(0, sb.Length)
    sb.Length = 0
sb.Append("abcde")
    var str: string = sb.ToString
sb.Delete(0, sb.Length - 0)
sb.Append("YY")
Assert.AreEqual("abcde", str)
Assert.AreEqual("YY", sb.ToString)
proc Test_Reverse*() =
    var fixture: string = "0123456789"
    var sb = OpenStringBuilder(32)
sb.Append(fixture)
sb.Reverse
Assert.AreEqual("9876543210", sb.ToString)
    sb.Length = 0
sb.Append("012345678")
sb.Reverse
Assert.AreEqual("876543210", sb.ToString)
    sb.Length = 1
sb.Reverse
Assert.AreEqual("8", sb.ToString)
    sb.Length = 0
sb.Reverse
Assert.AreEqual("", sb.ToString)
    var str: string
    str = "a"
reverseTest(str, str, str)
    str = "ab"
reverseTest(str, "ba", str)
    str = "abcdef"
reverseTest(str, "fedcba", str)
    str = "abcdefg"
reverseTest(str, "gfedcba", str)
    str = "𐀀"
reverseTest(str, str, str)
    str = "��"
reverseTest(str, "𐀀", "𐀀")
    str = "a𐀀"
reverseTest(str, "𐀀a", str)
    str = "ab𐀀"
reverseTest(str, "𐀀ba", str)
    str = "abc𐀀"
reverseTest(str, "𐀀cba", str)
    str = "𐀀��𐠂"
reverseTest(str, "𐠂𐐁𐀀", "𐀀𐐁𐠂")
    str = "𐀀𐐁𐠂"
reverseTest(str, "𐠂𐐁𐀀", str)
    str = "𐀀��a"
reverseTest(str, "a𐐁𐀀", "𐀀𐐁a")
    str = "a𐀀𐐁"
reverseTest(str, "𐐁𐀀a", str)
    str = "𐀀��ab"
reverseTest(str, "ba𐐁𐀀", "𐀀𐐁ab")
    str = "ab𐀀𐐁"
reverseTest(str, "𐐁𐀀ba", str)
    str = "𐀀𐐁"
reverseTest(str, "𐐁𐀀", str)
    str = "a𐀀z𐐁"
reverseTest(str, "𐐁z𐀀a", str)
    str = "a𐀀bz𐐁"
reverseTest(str, "𐐁zb𐀀a", str)
    str = "abc𐠂𐐁𐀀"
reverseTest(str, "𐀀𐐁𐠂cba", str)
    str = "abcd𐠂𐐁𐀀"
reverseTest(str, "𐀀𐐁𐠂dcba", str)
proc Test_IndexOf_String_CultureSensitivity*() =
    var fixture: string = "ዬ፡ዶጶቝአሄኢቌጕኬ቏ቖኋዘዻ፡ሆገኅጬሷ፜ቔቿ፺ዃጫቭዄ"
    var searchFor: string = "ሄኢቌጕኬ቏ቖኋዘዻ"
    var sb = OpenStringBuilder(fixture)
      let context = CultureContext("ru-MD")
<unhandled: nnkDefer>
Assert.AreEqual(6, sb.IndexOf(searchFor, StringComparison.Ordinal))
proc Test_IndexOf_String_CultureSensitivity_LargeString*() =
    var fixture: string = LargeUnicodeString + "ዬ፡ዶጶቝአሄኢቌጕኬ቏ቖኋዘዻ፡ሆገኅጬሷ፜ቔቿ፺ዃጫቭዄ"
    var searchFor: string = "ሄኢቌጕኬ቏ቖኋዘዻ"
    var sb = OpenStringBuilder(fixture)
      let context = CultureContext("ru-MD")
<unhandled: nnkDefer>
Assert.AreEqual(LargeUnicodeString.Length + 6, sb.IndexOf(searchFor, StringComparison.Ordinal))
proc Test_IndexOf_String_Int32_CultureSensitivity*() =
    var fixture: string = "ዬ፡ዶጶቝአሄኢቌጕኬ቏ቖኋዘዻ፡ሆገኅጬሷ፜ቔቿ፺ዃጫቭዄ"
    var searchFor: string = "ሄኢቌጕኬ቏ቖኋዘዻ"
    var sb = OpenStringBuilder(fixture)
      let context = CultureContext("ru-MD")
<unhandled: nnkDefer>
Assert.AreEqual(6, sb.IndexOf(searchFor, 4, StringComparison.Ordinal))
proc Test_IndexOf_String_Int32_CultureSensitivity_LargeString*() =
    var fixture: string = LargeUnicodeString + "ዬ፡ዶጶቝአሄኢቌጕኬ቏ቖኋዘዻ፡ሆገኅጬሷ፜ቔቿ፺ዃጫቭዄ"
    var searchFor: string = "ሄኢቌጕኬ቏ቖኋዘዻ"
    var sb = OpenStringBuilder(fixture)
      let context = CultureContext("ru-MD")
<unhandled: nnkDefer>
Assert.AreEqual(LargeUnicodeString.Length + 6, sb.IndexOf(searchFor, 4, StringComparison.Ordinal))
proc Test_LastIndexOf_String_CultureSensitivity*() =
    var fixture: string = "ዬ፡ዶጶቝአሄኢቌጕኬ቏ቖኋዘዻ፡ሆገኅጬሷ፜ቔቿ፺ዃጫቭዄ"
    var searchFor: string = "ሄኢቌጕኬ቏ቖኋዘዻ"
    var sb = OpenStringBuilder(fixture)
      let context = CultureContext("ru-MD")
<unhandled: nnkDefer>
Assert.AreEqual(6, sb.LastIndexOf(searchFor, StringComparison.Ordinal))
proc Test_LastIndexOf_String_CultureSensitivity_LargeString*() =
    var fixture: string = "ዬ፡ዶጶቝአሄኢቌጕኬ቏ቖኋዘዻ፡ሆገኅጬሷ፜ቔቿ፺ዃጫቭዄ" + LargeUnicodeString
    var searchFor: string = "ሄኢቌጕኬ቏ቖኋዘዻ"
    var sb = OpenStringBuilder(fixture)
      let context = CultureContext("ru-MD")
<unhandled: nnkDefer>
Assert.AreEqual(6, sb.LastIndexOf(searchFor, StringComparison.Ordinal))
proc Test_LastIndexOf_String_Int32_CultureSensitivity*() =
    var fixture: string = "ዬ፡ዶጶቝአሄኢቌጕኬ቏ቖኋዘዻ፡ሆገኅጬሷ፜ቔቿ፺ዃጫቭዄ"
    var searchFor: string = "ሄኢቌጕኬ቏ቖኋዘዻ"
    var sb = OpenStringBuilder(fixture)
      let context = CultureContext("ru-MD")
<unhandled: nnkDefer>
Assert.AreEqual(6, sb.LastIndexOf(searchFor, 20, StringComparison.Ordinal))
proc Test_LastIndexOf_String_Int32_CultureSensitivity_LargeString*() =
    var fixture: string = "ዬ፡ዶጶቝአሄኢቌጕኬ቏ቖኋዘዻ፡ሆገኅጬሷ፜ቔቿ፺ዃጫቭዄ" + LargeUnicodeString
    var searchFor: string = "ሄኢቌጕኬ቏ቖኋዘዻ"
    var sb = OpenStringBuilder(fixture)
      let context = CultureContext("ru-MD")
<unhandled: nnkDefer>
Assert.AreEqual(6, sb.LastIndexOf(searchFor, LargeUnicodeString.Length - 20, StringComparison.Ordinal))