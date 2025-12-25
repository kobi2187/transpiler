# "Namespace: ICU4N.Dev.Test.Collate"
type
  AlphabeticIndexTest = ref object
    ARROW: string = "→"
    DEBUG: bool = ICUDebug.Enabled("alphabeticindex")
    KEY_LOCALES: IList[string] = List<string>
    localeAndIndexCharactersLists: seq[string] = @[@["ar", "ا:ب:ت:ث:ج:ح:خ:د:ذ:ر:ز:س:ش:ص:ض:ط:ظ:ع:غ:ف:ق:ك:ل:م:ن:ه:و:ي"], @["bg", "А:Б:В:Г:Д:Е:Ж:З:И:Й:К:Л:М:Н:О:П:Р:С:Т:У:Ф:Х:Ц:Ч:Ш:Щ:Ю:Я"], @["ca", "A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z"], @["cs", "A:B:C:Č:D:E:F:G:H:CH:I:J:K:L:M:N:O:P:Q:R:Ř:S:Š:T:U:V:W:X:Y:Z:Ž"], @["da", "A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z:Æ:Ø:Å"], @["de", "A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z"], @["el", "Α:Β:Γ:Δ:Ε:Ζ:Η:Θ:Ι:Κ:Λ:Μ:Ν:Ξ:Ο:Π:Ρ:Σ:Τ:Υ:Φ:Χ:Ψ:Ω"], @["en", "A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z"], @["es", "A:B:C:D:E:F:G:H:I:J:K:L:M:N:Ñ:O:P:Q:R:S:T:U:V:W:X:Y:Z"], @["et", "A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:Š:Z:Ž:T:U:V:Õ:Ä:Ö:Ü:X:Y"], @["eu", "A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z"], @["fi", "A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z:Å:Ä:Ö"], @["fil", "A:B:C:D:E:F:G:H:I:J:K:L:M:N:Ñ:Ng:O:P:Q:R:S:T:U:V:W:X:Y:Z"], @["fr", "A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z"], @["he", "א:ב:ג:ד:ה:ו:ז:ח:ט:י:כ:ל:מ:נ:ס:ע:פ:צ:ק:ר:ש:ת"], @["is", "A:Á:B:C:D:Ð:E:É:F:G:H:I:Í:J:K:L:M:N:O:Ó:P:Q:R:S:T:U:Ú:V:W:X:Y:Ý:Z:Þ:Æ:Ö"], @["it", "A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z"], @["ja", "あ:か:さ:た:な:は:ま:や:ら:わ"], @["ko", "ㄱ:ㄴ:ㄷ:ㄹ:ㅁ:ㅂ:ㅅ:ㅇ:ㅈ:ㅊ:ㅋ:ㅌ:ㅍ:ㅎ"], @["lt", "A:B:C:Č:D:E:F:G:H:I:J:K:L:M:N:O:P:R:S:Š:T:U:V:Z:Ž"], @["lv", "A:B:C:Č:D:E:F:G:Ģ:H:I:J:K:Ķ:L:Ļ:M:N:Ņ:O:P:Q:R:S:Š:T:U:V:W:X:Z:Ž"], @["nb", "A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z:Æ:Ø:Å"], @["nl", "A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z"], @["pl", "A:Ą:B:C:Ć:D:E:Ę:F:G:H:I:J:K:L:Ł:M:N:Ń:O:Ó:P:Q:R:S:Ś:T:U:V:W:X:Y:Z:Ź:Ż"], @["pt", "A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z"], @["ro", "A:Ă:Â:B:C:D:E:F:G:H:I:Î:J:K:L:M:N:O:P:Q:R:S:Ș:T:Ț:U:V:W:X:Y:Z"], @["ru", "А:Б:В:Г:Д:Е:Ж:З:И:Й:К:Л:М:Н:О:П:Р:С:Т:У:Ф:Х:Ц:Ч:Ш:Щ:Ы:Э:Ю:Я"], @["sk", "A:Ä:B:C:Č:D:E:F:G:H:CH:I:J:K:L:M:N:O:Ô:P:Q:R:S:Š:T:U:V:W:X:Y:Z:Ž"], @["sl", "A:B:C:Č:Ć:D:Đ:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:Š:T:U:V:W:X:Y:Z:Ž"], @["sr", "А:Б:В:Г:Д:Ђ:Е:Ж:З:И:Ј:К:Л:Љ:М:Н:Њ:О:П:Р:С:Т:Ћ:У:Ф:Х:Ц:Ч:Џ:Ш"], @["sv", "A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z:Å:Ä:Ö"], @["tr", "A:B:C:Ç:D:E:F:G:H:I:İ:J:K:L:M:N:O:Ö:P:Q:R:S:Ş:T:U:Ü:V:W:X:Y:Z"], @["uk", "А:Б:В:Г:Ґ:Д:Е:Є:Ж:З:И:І:Ї:Й:К:Л:М:Н:О:П:Р:С:Т:У:Ф:Х:Ц:Ч:Ш:Щ:Ю:Я"], @["vi", "A:Ă:Â:B:C:D:Đ:E:Ê:F:G:H:I:J:K:L:M:N:O:Ô:Ơ:P:Q:R:S:T:U:Ư:V:W:X:Y:Z"], @["zh", "A:B:C:D:E:F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z"], @["zh_Hant", "1劃:2劃:3劃:4劃:5劃:6劃:7劃:8劃:9劃:10劃:11劃:12劃:13劃:14劃:15劃:16劃:17劃:18劃:19劃:20劃:21劃:22劃:23劃:24劃:25劃:26劃:27劃:28劃:29劃:30劃:31劃:32劃:33劃:35劃:36劃:39劃:48劃"]]
    TO_TRY: UnicodeSet = UnicodeSet("[[:^nfcqc=no:]-[:sc=Common:]-[:sc=Inherited:]-[:sc=Unknown:]]").Freeze
    SimpleTests: seq[String] = @["斎藤", "Ἥρα", "$", "£", "12", "2", "Davis", "Davis", "Abbot", "ᴅavis", "Zach", "ᴅavis", "Ƶ", "İstanbul", "Istanbul", "istanbul", "ıstanbul", "Þor", "Åberg", "Östlund", "Ἥρα", "Ἀθηνᾶ", "Ζεύς", "Ποσειδὣν", "Ἅιδης", "Δημήτηρ", "Ἑστιά", "斉藤", "佐藤", "鈴木", "高橋", "田中", "渡辺", "伊藤", "山本", "中村", "小林", "斎藤", "加藤"]
    hackPinyin: seq[String] = @["a", "吖", "墺", "b", "八", "拔", "蔀", "c", "嚓", "礸", "鹾", "d", "咑", "迏", "陊", "e", "妸", "鋨", "荋", "f", "发", "醗", "馥", "g", "猤", "釓", "腂", "h", "妎", "鉿", "夻", "j", "丌", "枅", "鵘", "k", "咔", "開", "穒", "l", "垃", "拉", "鮥", "m", "嘸", "麻", "旀", "n", "拿", "肭", "桛", "o", "噢", "毮", "讴", "p", "妑", "耙", "谱", "q", "七", "恓", "罖", "r", "呥", "犪", "渃", "s", "仨", "钑", "鏁", "t", "他", "鉈", "柝", "w", "屲", "啘", "婺", "x", "夕", "吸", "殾", "y", "丫", "芽", "蕴", "z", "帀", "災", "尊"]
    simplifiedNames: seq[String] = @["Abbot", "Morton", "Zachary", "Williams", "赵", "钱", "孙", "李", "周", "吴", "郑", "王", "冯", "陈", "楮", "卫", "蒋", "沈", "韩", "杨", "朱", "秦", "尤", "许", "何", "吕", "施", "张", "孔", "曹", "严", "华", "金", "魏", "陶", "姜", "戚", "谢", "邹", "喻", "柏", "水", "窦", "章", "云", "苏", "潘", "葛", "奚", "范", "彭", "郎", "鲁", "韦", "昌", "马", "苗", "凤", "花", "方", "俞", "任", "袁", "柳", "酆", "鲍", "史", "唐", "费", "廉", "岑", "薛", "雷", "贺", "倪", "汤", "滕", "殷", "罗", "毕", "郝", "邬", "安", "常", "乐", "于", "时", "傅", "皮", "卞", "齐", "康", "伍", "余", "元", "卜", "顾", "孟", "平", "黄", "和", "穆", "萧", "尹", "姚", "邵", "湛", "汪", "祁", "毛", "禹", "狄", "米", "贝", "明", "臧", "计", "伏", "成", "戴", "谈", "宋", "茅", "庞", "熊", "纪", "舒", "屈", "项", "祝", "董", "梁", "杜", "阮", "蓝", "闽", "席", "季", "麻", "强", "贾", "路", "娄", "危", "江", "童", "颜", "郭", "梅", "盛", "林", "刁", "锺", "徐", "丘", "骆", "高", "夏", "蔡", "田", "樊", "胡", "凌", "霍", "虞", "万", "支", "柯", "昝", "管", "卢", "莫", "经", "房", "裘", "缪", "干", "解", "应", "宗", "丁", "宣", "贲", "邓", "郁", "单", "杭", "洪", "包", "诸", "左", "石", "崔", "吉", "钮", "龚", "程", "嵇", "邢", "滑", "裴", "陆", "荣", "翁", "荀", "羊", "於", "惠", "甄", "麹", "家", "封", "芮", "羿", "储", "靳", "汲", "邴", "糜", "松", "井", "段", "富", "巫", "乌", "焦", "巴", "弓", "牧", "隗", "山", "谷", "车", "侯", "宓", "蓬", "全", "郗", "班", "仰", "秋", "仲", "伊", "宫", "宁", "仇", "栾", "暴", "甘", "斜", "厉", "戎", "祖", "武", "符", "刘", "景", "詹", "束", "龙", "叶", "幸", "司", "韶", "郜", "黎", "蓟", "薄", "印", "宿", "白", "怀", "蒲", "邰", "从", "鄂", "索", "咸", "籍", "赖", "卓", "蔺", "屠", "蒙", "池", "乔", "阴", "郁", "胥", "能", "苍", "双", "闻", "莘", "党", "翟", "谭", "贡", "劳", "逄", "姬", "申", "扶", "堵", "冉", "宰", "郦", "雍", "郤", "璩", "桑", "桂", "濮", "牛", "寿", "通", "边", "扈", "燕", "冀", "郏", "浦", "尚", "农", "温", "别", "庄", "晏", "柴", "瞿", "阎", "充", "慕", "连", "茹", "习", "宦", "艾", "鱼", "容", "向", "古", "易", "慎", "戈", "廖", "庾", "终", "暨", "居", "衡", "步", "都", "耿", "满", "弘", "匡", "国", "文", "寇", "广", "禄", "阙", "东", "欧", "殳", "沃", "利", "蔚", "越", "夔", "隆", "师", "巩", "厍", "聂", "晁", "勾", "敖", "融", "冷", "訾", "辛", "阚", "那", "简", "饶", "空", "曾", "毋", "沙", "乜", "养", "鞠", "须", "丰", "巢", "关", "蒯", "相", "查", "后", "荆", "红", "游", "竺", "权", "逑", "盖", "益", "桓", "公", "万俟", "司马", "上官", "欧阳", "夏侯", "诸葛", "闻人", "东方", "赫连", "皇甫", "尉迟", "公羊", "澹台", "公冶", "宗政", "濮阳", "淳于", "单于", "太叔", "申屠", "公孙", "仲孙", "轩辕", "令狐", "锺离", "宇文", "长孙", "慕容", "鲜于", "闾丘", "司徒", "司空", "丌官", "司寇", "仉", "督", "子车", "颛孙", "端木", "巫马", "公西", "漆雕", "乐正", "壤驷", "公良", "拓拔", "夹谷", "宰父", "谷梁", "晋", "楚", "阎", "法", "汝", "鄢", "涂", "钦", "段干", "百里", "东郭", "南门", "呼延", "归", "海", "羊舌", "微生", "岳", "帅", "缑", "亢", "况", "后", "有", "琴", "梁丘", "左丘", "东门", "西门", "商", "牟", "佘", "佴", "伯", "赏", "南宫", "墨", "哈", "谯", "笪", "年", "爱", "阳", "佟"]
    traditionalNames: seq[String] = @["丁", "Abbot", "Morton", "Zachary", "Williams", "趙", "錢", "孫", "李", "周", "吳", "鄭", "王", "馮", "陳", "楮", "衛", "蔣", "沈", "韓", "楊", "朱", "秦", "尤", "許", "何", "呂", "施", "張", "孔", "曹", "嚴", "華", "金", "魏", "陶", "姜", "戚", "謝", "鄒", "喻", "柏", "水", "竇", "章", "雲", "蘇", "潘", "葛", "奚", "範", "彭", "郎", "魯", "韋", "昌", "馬", "苗", "鳳", "花", "方", "俞", "任", "袁", "柳", "酆", "鮑", "史", "唐", "費", "廉", "岑", "薛", "雷", "賀", "倪", "湯", "滕", "殷", "羅", "畢", "郝", "鄔", "安", "常", "樂", "於", "時", "傅", "皮", "卞", "齊", "康", "伍", "餘", "元", "卜", "顧", "孟", "平", "黃", "和", "穆", "蕭", "尹", "姚", "邵", "湛", "汪", "祁", "毛", "禹", "狄", "米", "貝", "明", "臧", "計", "伏", "成", "戴", "談", "宋", "茅", "龐", "熊", "紀", "舒", "屈", "項", "祝", "董", "梁", "杜", "阮", "藍", "閩", "席", "季", "麻", "強", "賈", "路", "婁", "危", "江", "童", "顏", "郭", "梅", "盛", "林", "刁", "鍾", "徐", "丘", "駱", "高", "夏", "蔡", "田", "樊", "胡", "凌", "霍", "虞", "萬", "支", "柯", "昝", "管", "盧", "莫", "經", "房", "裘", "繆", "幹", "解", "應", "宗", "丁", "宣", "賁", "鄧", "鬱", "單", "杭", "洪", "包", "諸", "左", "石", "崔", "吉", "鈕", "龔", "程", "嵇", "邢", "滑", "裴", "陸", "榮", "翁", "荀", "羊", "於", "惠", "甄", "麴", "家", "封", "芮", "羿", "儲", "靳", "汲", "邴", "糜", "松", "井", "段", "富", "巫", "烏", "焦", "巴", "弓", "牧", "隗", "山", "谷", "車", "侯", "宓", "蓬", "全", "郗", "班", "仰", "秋", "仲", "伊", "宮", "寧", "仇", "欒", "暴", "甘", "斜", "厲", "戎", "祖", "武", "符", "劉", "景", "詹", "束", "龍", "葉", "幸", "司", "韶", "郜", "黎", "薊", "薄", "印", "宿", "白", "懷", "蒲", "邰", "從", "鄂", "索", "咸", "籍", "賴", "卓", "藺", "屠", "蒙", "池", "喬", "陰", "鬱", "胥", "能", "蒼", "雙", "聞", "莘", "黨", "翟", "譚", "貢", "勞", "逄", "姬", "申", "扶", "堵", "冉", "宰", "酈", "雍", "郤", "璩", "桑", "桂", "濮", "牛", "壽", "通", "邊", "扈", "燕", "冀", "郟", "浦", "尚", "農", "溫", "別", "莊", "晏", "柴", "瞿", "閻", "充", "慕", "連", "茹", "習", "宦", "艾", "魚", "容", "向", "古", "易", "慎", "戈", "廖", "庾", "終", "暨", "居", "衡", "步", "都", "耿", "滿", "弘", "匡", "國", "文", "寇", "廣", "祿", "闕", "東", "歐", "殳", "沃", "利", "蔚", "越", "夔", "隆", "師", "鞏", "厙", "聶", "晁", "勾", "敖", "融", "冷", "訾", "辛", "闞", "那", "簡", "饒", "空", "曾", "毋", "沙", "乜", "養", "鞠", "須", "豐", "巢", "關", "蒯", "相", "查", "後", "荊", "紅", "遊", "竺", "權", "逑", "蓋", "益", "桓", "公", "万俟", "司馬", "上官", "歐陽", "夏侯", "諸葛", "聞人", "東方", "赫連", "皇甫", "尉遲", "公羊", "澹台", "公冶", "宗政", "濮陽", "淳于", "單于", "太叔", "申屠", "公孫", "仲孫", "軒轅", "令狐", "鍾離", "宇文", "長孫", "慕容", "鮮于", "閭丘", "司徒", "司空", "丌官", "司寇", "仉", "督", "子車", "顓孫", "端木", "巫馬", "公西", "漆雕", "樂正", "壤駟", "公良", "拓拔", "夾谷", "宰父", "穀梁", "晉", "楚", "閻", "法", "汝", "鄢", "塗", "欽", "段干", "百里", "東郭", "南門", "呼延", "歸", "海", "羊舌", "微生", "岳", "帥", "緱", "亢", "況", "後", "有", "琴", "梁丘", "左丘", "東門", "西門", "商", "牟", "佘", "佴", "伯", "賞", "南宮", "墨", "哈", "譙", "笪", "年", "愛", "陽", "佟", "㐁", "㐢", "㐦", "㒓", "㒥", "㒧", "㒪", "㔶", "䨻", "一", "丁", "万", "不", "丗", "丣", "並", "临", "亂", "亸", "亹", "償", "儭", "儽", "儾", "厵", "囔", "囖", "灥", "灩", "灪", "纞", "靐", "齉", "齾", "龘", "𠀵", "𠀽", "𠀾", "𠁁", "𠁆", "𠁌", "𠁎", "𠁓", "𠁕", "𠁖", "𠁟", "𠁠", "𠁺", "𠁻", "𠃈", "𠆞", "𠆟", "𠆠", "𠆡", "𠔻", "𠣊", "𠣋", "𠥬", "𠨋", "𠨌", "𠫑", "𡆟", "𡔙", "𡔚", "𡤻", "𣍜", "𦧄", "𦧅", "𧆘", "𧢱", "𨐄", "𩇓", "𩙣", "𪓊", "𪺚"]

proc TestA*() =
    var tests: String[][] = @[@["zh_Hant", "渡辺", "12劃"], @["zh", "渡辺", "D"]]
    for test in tests:
        var alphabeticIndex: AlphabeticIndex<int> = AlphabeticIndex<int>(UCultureInfo(test[0]))
        var probe: String = test[1]
        var expectedLabel: String = test[2]
alphabeticIndex.AddRecord(probe, 1)
        var labels: IList<string> = alphabeticIndex.GetBucketLabels
Logln(string.Format(StringFormatter.CurrentCulture, "{0}", labels))
        var bucket = Find(alphabeticIndex, probe)
assertEquals("locale " + test[0] + " name=" + probe + " in bucket", expectedLabel, bucket.Label)
proc Find(alphabeticIndex: AlphabeticIndex[int], probe: string): Bucket<int> =
    for bucket in alphabeticIndex:
        for record in bucket:
            if record.Name.Span.Equals(probe, StringComparison.Ordinal):
                return bucket
    return nil
proc TestFirstCharacters*() =
    var alphabeticIndex: AlphabeticIndex<object> = AlphabeticIndex<object>(CultureInfo("en"))
    var collator: RuleBasedCollator = alphabeticIndex.Collator
    collator.Strength = Collator.Identical
    var firsts: ICollection<String> = alphabeticIndex.GetFirstCharactersInScripts
    var missingScripts: UnicodeSet = UnicodeSet("[^[:inherited:][:unknown:][:common:][:Braille:][:SignWriting:]]")
    var last: String = ""
    for index in firsts:
        if collator.Compare(last, index) >= 0:
Errln("Characters not in order: " + last + " !< " + index)
        var script: int = GetFirstRealScript(index)
        if script == UScript.Unknown:
            continue
        var s: UnicodeSet = UnicodeSet.ApplyInt32PropertyValue(UProperty.Script, script)
        if missingScripts.ContainsNone(s):
Errln("2nd character in script: " + index + "	" + UnicodeSet(missingScripts).RetainAll(s).ToPattern(false))
missingScripts.RemoveAll(s)
    if missingScripts.Count != 0:
        var missingScriptNames: String = ""
        var missingChars: UnicodeSet = UnicodeSet(missingScripts)
          while true:
              var c: int = missingChars[0]
              if c < 0:
                  break
              var script: int = UScript.GetScript(c)
              missingScriptNames = " " + UChar.GetPropertyValueName(UProperty.Script, script, NameChoice.Short)
missingChars.RemoveAll(UnicodeSet.ApplyInt32PropertyValue(UProperty.Script, script))
Errln("Missing character from:" + missingScriptNames + " -- " + missingScripts)
proc GetFirstRealScript(s: string): int =
      var i: int = 0
      while i < s.Length:
          var c: int = Character.CodePointAt(s, i)
          var script: int = UScript.GetScript(c)
          if script != UScript.Unknown && script != UScript.Inherited && script != UScript.Common:
              return script
          i = Character.CharCount(c)
    return UScript.Unknown
proc TestBuckets*() =
    var additionalLocale: UCultureInfo = UCultureInfo("en")
    for pair in localeAndIndexCharactersLists:
CheckBuckets(pair[0], SimpleTests, additionalLocale, "E", "edgar", "Effron", "Effron")
proc TestEmpty*() =
    var locales: List<UCultureInfo> = List<UCultureInfo>
locales.Add(UCultureInfo.InvariantCulture)
locales.AddRange(UCultureInfo.GetCultures(UCultureTypes.AllCultures))
    for locale in locales:
        try:
            var alphabeticIndex: AlphabeticIndex<string> = AlphabeticIndex<string>(locale)
alphabeticIndex.AddRecord("hi", "HI")
            for bucket in alphabeticIndex:
                var labelType: BucketLabelType = bucket.LabelType
        except Exception:
Errln("Exception when creating AlphabeticIndex for:	" + locale.IetfLanguageTag)
Errln(e.ToString)
proc TestSetGetSpecialLabels*() =
    var index: AlphabeticIndex<object> = AlphabeticIndex<object>(CultureInfo("de")).AddLabels(CultureInfo("ru"))
index.SetUnderflowLabel("__")
index.SetInflowLabel("--")
index.SetOverflowLabel("^^")
assertEquals("underflow label", "__", index.UnderflowLabel)
assertEquals("inflow label", "--", index.InflowLabel)
assertEquals("overflow label", "^^", index.OverflowLabel)
    var ii: ImmutableIndex<object> = index.BuildImmutableIndex
assertEquals("0 -> underflow", "__", ii.GetBucket(ii.GetBucketIndex("0")).Label)
assertEquals("Ω -> inflow", "--", ii.GetBucket(ii.GetBucketIndex("Ω")).Label)
assertEquals("字 -> overflow", "^^", ii.GetBucket(ii.GetBucketIndex("字")).Label)
proc TestInflow*() =
    var tests: object[][] = @[@[0, UCultureInfo("en")], @[0, UCultureInfo("en"), UCultureInfo("el")], @[1, UCultureInfo("en"), UCultureInfo("ru")], @[0, UCultureInfo("en"), UCultureInfo("el"), UnicodeSet("[Ⲁ]"), UCultureInfo("ru")], @[0, UCultureInfo("en")], @[2, UCultureInfo("en"), UCultureInfo("ru"), UCultureInfo("ja")]]
    for test in tests:
        var expected: int = cast[int](test[0])
        var alphabeticIndex: AlphabeticIndex<double> = AlphabeticIndex<double>(cast[UCultureInfo](test[1]))
          var i: int = 2
          while i < test.Length:
              if test[i] is UCultureInfo:
alphabeticIndex.AddLabels(cast[UCultureInfo](test[i]))
              else:
alphabeticIndex.AddLabels(cast[UnicodeSet](test[i]))
++i
        var counter: Counter<BucketLabelType> = Counter<BucketLabelType>
        for bucket in alphabeticIndex:
            var labelType = bucket.LabelType
counter.Add(labelType, 1)
        var printList: String = string.Format(StringFormatter.CurrentCulture, "{0}", cast[object](test))
assertEquals(BucketLabelType.Underflow + "	" + printList, 1, counter.Get(BucketLabelType.Underflow))
assertEquals(BucketLabelType.Inflow + "	" + printList, expected, counter.Get(BucketLabelType.Inflow))
        if expected != counter.Get(BucketLabelType.Inflow):
            var indexCharacters2: AlphabeticIndex<Double> = AlphabeticIndex<double>(cast[UCultureInfo](test[1]))
              var i: int = 2
              while i < test.Length:
                  if test[i] is UCultureInfo:
indexCharacters2.AddLabels(cast[UCultureInfo](test[i]))
                  else:
indexCharacters2.AddLabels(cast[UnicodeSet](test[i]))
++i
            var buckets: List<Bucket<double>> = List<Bucket<double>>(alphabeticIndex)
Logln(buckets.ToString)
assertEquals(BucketLabelType.Overflow + "	" + printList, 1, counter.Get(BucketLabelType.Overflow))
proc CheckBuckets(localeString: string, test: seq[string], additionalLocale: UCultureInfo, testBucket: string, items: seq[string]) =
    var UI: StringBuilder = StringBuilder
    var desiredLocale: UCultureInfo = UCultureInfo(localeString)
    var index: AlphabeticIndex<int> = AlphabeticIndex<int>(desiredLocale).AddLabels(additionalLocale)
    var counter: int = 0
    var itemCount: Counter<string> = Counter<string>
    for item in test:
index.AddRecord(item, ++counter)
itemCount.Add(item, 1)
assertEquals("getRecordCount()", cast[int](itemCount.GetTotal), index.RecordCount)
    var labels: IList<string> = index.GetBucketLabels
    var immIndex = index.BuildImmutableIndex
Logln(desiredLocale + "	" + desiredLocale.GetDisplayName(UCultureInfo("en")) + " - " + desiredLocale.GetDisplayName(desiredLocale) + "	" + index.Collator.ActualCulture)
    UI.Length = 0
UI.Append(desiredLocale + "	")
    var showAll: bool = true
    for bucket in index:
        if showAll || bucket.Count != 0:
ShowLabelAtTop(UI, bucket.Label)
Logln(UI.ToString)
    var bucketIndex: int = 0
    for bucket in index:
assertEquals("bucket label vs. iterator", labels[bucketIndex], bucket.Label)
assertEquals("bucket label vs. immutable", labels[bucketIndex], immIndex.GetBucket(bucketIndex).Label)
assertEquals("bucket label type vs. immutable", bucket.LabelType, immIndex.GetBucket(bucketIndex).LabelType)
        for r in bucket:
            var name: ReadOnlyMemory<char> = r.Name
assertEquals("getBucketIndex(" + name.ToString + ")", bucketIndex, index.GetBucketIndex(name))
assertEquals("immutable getBucketIndex(" + name.ToString + ")", bucketIndex, immIndex.GetBucketIndex(name))
        if bucket.Label.Equals(testBucket):
            var keys: Counter<String> = GetKeys(bucket)
            for item in items:
                var globalCount: long = itemCount.Get(item)
                var localeCount: long = keys.Get(item)
                if globalCount != localeCount:
Errln("Error: in " + "'" + testBucket + "', '" + item + "' should have count " + globalCount + " but has count " + localeCount)
        if bucket.Count != 0:
ShowLabelInList(UI, bucket.Label)
            for item in bucket:
ShowIndexedItem(UI, item.Name, item.Data)
Logln(UI.ToString)
++bucketIndex
assertEquals("getBucketCount()", bucketIndex, index.BucketCount)
assertEquals("immutable getBucketCount()", bucketIndex, immIndex.BucketCount)
assertNull("immutable getBucket(-1)", immIndex.GetBucket(-1))
assertNull("immutable getBucket(count)", immIndex.GetBucket(bucketIndex))
    for bucket in immIndex:
assertEquals("immutable bucket size", 0, bucket.Count)
assertFalse("immutable bucket iterator.hasNext()", bucket.GetEnumerator.MoveNext)
proc ShowIndex*(index: AlphabeticIndex[T], showEmpty: bool) =
Logln("Actual")
    var UI: StringBuilder = StringBuilder
    for bucket in index:
        if showEmpty || bucket.Count != 0:
ShowLabelInList(UI, bucket.Label)
            for item in bucket:
ShowIndexedItem(UI, item.Name, item.Data)
Logln(UI.ToString)
proc ShowIndex(myBucketLabels: IList[String], myBucketContents: List[ISet<Row<RawCollationKey, string, int, double>>], showEmpty: bool) =
Logln("Alternative")
    var UI: StringBuilder = StringBuilder
      var i: int = 0
      while i < myBucketLabels.Count:
          var bucket = myBucketContents[i]
          if !showEmpty && bucket.Count == 0:
              continue
          UI.Length = 0
UI.Append("*").Append(myBucketLabels[i])
          for item in bucket:
UI.Append("	 ").Append(item.Get1.ToString).Append(ARROW).Append(item.Get3.ToString)
Logln(UI.ToString)
++i
proc ShowLabelAtTop(buffer: StringBuilder, label: String) =
buffer.Append(label + " ")
proc ShowIndexedItem(buffer: StringBuilder, key: ReadOnlyMemory[char], value: T) =
buffer.Append("	 ")
buffer.Append(key.Span)
buffer.Append(ARROW)
buffer.Append(value)
proc ShowLabelInList(buffer: StringBuilder, label: String) =
    buffer.Length = 0
buffer.Append(label)
proc GetKeys(entry: Bucket[int]): Counter<String> =
    var keys: Counter<String> = Counter<String>
    for x in entry:
        var key: String = x.Name.ToString
keys.Add(key, 1)
    return keys
proc TestIndexCharactersList*() =
    for localeAndIndexCharacters in localeAndIndexCharactersLists:
        var locale: UCultureInfo = UCultureInfo(localeAndIndexCharacters[0])
        var expectedIndexCharacters: String = "…:" + localeAndIndexCharacters[1] + ":…"
        var alphabeticIndex: ICollection<string> = AlphabeticIndex<string>(locale).GetBucketLabels
        var sb: StringBuilder = StringBuilder
          let iter = alphabeticIndex.GetEnumerator
<unhandled: nnkDefer>
          var first: bool = true
          while iter.MoveNext:
              if first:
                first = false
              else:
sb.Append(":")
sb.Append(iter.Current)
        var actualIndexCharacters: String = sb.ToString
        if !expectedIndexCharacters.Equals(actualIndexCharacters):
Errln("Test failed for locale " + localeAndIndexCharacters[0] + "
  Expected = |" + expectedIndexCharacters + "|
  actual   = |" + actualIndexCharacters + "|")
proc TestBasics*() =
    var list: UCultureInfo[] = UCultureInfo.GetCultures(UCultureTypes.AllCultures)
    var keywords: List<object> = List<object>
keywords.Add("")
    var collationValues: String[] = Collator.GetKeywordValues("collation")
      var j: int = 0
      while j < collationValues.Length:
keywords.Add("@collation=" + collationValues[j])
++j
      var i: int = 0
      while i < list.Length:
          for collationValue in keywords:
              var localeString: string = list[i].ToString
              if !KEY_LOCALES.Contains(localeString):
                continue
              var locale: UCultureInfo = UCultureInfo(localeString + collationValue)
              if collationValue.Length > 0 && !Collator.GetFunctionalEquivalent("collation", locale).Equals(locale):
                  continue
              if locale.Country.Length != 0:
                  continue
              var isUnihan: bool = collationValue.Contains("unihan")
              var alphabeticIndex: AlphabeticIndex<object> = AlphabeticIndex<object>(locale)
              if isUnihan:
alphabeticIndex.SetMaxLabelCount(500)
              var mainChars = alphabeticIndex.GetBucketLabels
              var mainCharString: string = mainChars.ToString
              if mainCharString.Length > 500:
                  mainCharString = mainCharString.Substring(0, 500) + "..."
Logln(mainChars.Count + "	" + locale + "	" + locale.GetDisplayName(UCultureInfo("en")))
Logln("Index:	" + mainCharString)
              if !isUnihan && mainChars.Count > 100:
Errln("Index character set too large: " + locale + " [" + mainChars.Count + "]:
    " + mainChars)
++i
proc TestClientSupport*() =
    for localeString in @["zh"]:
        var ulocale: UCultureInfo = UCultureInfo(localeString)
        var alphabeticIndex: AlphabeticIndex<Double> = AlphabeticIndex<Double>(ulocale).AddLabels(CultureInfo("en"))
        var collator: RuleBasedCollator = alphabeticIndex.Collator
        var tests: String[][]
        if !localeString.Equals("zh"):
            tests = @[SimpleTests]
        else:
            tests = @[SimpleTests, hackPinyin, simplifiedNames]
        for shortTest in tests:
            var testValue: double = 100
alphabeticIndex.ClearRecords
            for name in shortTest:
alphabeticIndex.AddRecord(name, ++testValue)
            if DEBUG:
ShowIndex(alphabeticIndex, false)
            testValue = 100
            var myBucketLabels: IList<String> = alphabeticIndex.GetBucketLabels
            var myBucketContents = List<ISet<Row<RawCollationKey, string, int, double>>>(myBucketLabels.Count)
              var i: int = 0
              while i < myBucketLabels.Count:
myBucketContents.Add(SortedSet<Row<RawCollationKey, string, int, double>>)
++i
            for name in shortTest:
                var bucketIndex: int = alphabeticIndex.GetBucketIndex(name)
                if bucketIndex > myBucketContents.Count:
alphabeticIndex.GetBucketIndex(name)
                var myBucket = myBucketContents[bucketIndex]
                var rawCollationKey: RawCollationKey = collator.GetRawCollationKey(name, nil)
                var row = Row<RawCollationKey, string, int, double>(rawCollationKey, name, name.Length, ++testValue)
myBucket.Add(row)
            if DEBUG:
ShowIndex(myBucketLabels, myBucketContents, false)
            var index: int = 0
            var gotError: bool = false
            for bucket in alphabeticIndex:
                var bucketLabel: String = bucket.Label
                var myLabel: String = myBucketLabels[index]
                if !bucketLabel.Equals(myLabel):
                    gotError = !assertEquals(ulocale + "	Bucket Labels (" + index + ")", bucketLabel, myLabel)
                var myBucket = myBucketContents[index]
                  let myBucketIterator = myBucket.GetEnumerator
<unhandled: nnkDefer>
                  var recordIndex: int = 0
                  for record in bucket:
                      var myName: String = nil
                      if myBucketIterator.MoveNext:
                          var myRecord = myBucketIterator.Current
                          myName = myRecord.Get1
                      if !record.Name.Equals(myName):
                          gotError = !assertEquals(ulocale + "	" + bucketLabel + "	" + "Record Names (" + index + "." + ++recordIndex + ")", record.Name.ToString, myName)
                  while myBucketIterator.MoveNext:
                      var myRecord = myBucketIterator.Current
                      var myName: String = myRecord.Get1
                      gotError = !assertEquals(ulocale + "	" + bucketLabel + "	" + "Record Names (" + index + "." + ++recordIndex + ")", nil, myName)
++index
            if gotError:
ShowIndex(myBucketLabels, myBucketContents, false)
ShowIndex(alphabeticIndex, false)
proc TestFirstScriptCharacters*() =
    var firstCharacters: ICollection<String> = AlphabeticIndex<string>(UCultureInfo("en")).GetFirstCharactersInScripts
    var expectedFirstCharacters: ICollection<String> = FirstStringsInScript(cast[RuleBasedCollator](Collator.GetInstance(UCultureInfo.InvariantCulture)))
    var diff: ISet<String> = SortedSet<String>(firstCharacters, StringComparer.Ordinal)
diff.ExceptWith(expectedFirstCharacters)
assertTrue("First Characters contains unexpected ones: " + diff, diff.Count == 0)
diff.Clear
diff.UnionWith(expectedFirstCharacters)
diff.ExceptWith(firstCharacters)
assertTrue("First Characters missing expected ones: " + diff, diff.Count == 0)
proc FirstStringsInScript(ruleBasedCollator: RuleBasedCollator): ICollection<String> =
    var results: String[] = seq[String]
    for current in TO_TRY:
        if ruleBasedCollator.Compare(current, "a") < 0:
            continue
        var script: int = cast[int](UScript.GetScript(current.CodePointAt(0)))
        if results[script] == nil:
            results[script] = current

        elif ruleBasedCollator.Compare(current, results[script]) < 0:
            results[script] = current
    try:
        var extras: UnicodeSet = UnicodeSet
        var expansions: UnicodeSet = UnicodeSet
ruleBasedCollator.GetContractionsAndExpansions(extras, expansions, true)
extras.AddAll(expansions).RemoveAll(TO_TRY)
        if extras.Count != 0:
            var normalizer: Normalizer2 = Normalizer2.NFKCInstance
            for current in extras:
                if !normalizer.IsNormalized(current) || ruleBasedCollator.Compare(current, "9") <= 0:
                    continue
                var script: int = cast[int](GetFirstRealScript(current))
                if script == UScript.Unknown && !IsUnassignedBoundary(current):
                    continue
                if results[script] == nil:
                    results[script] = current

                elif ruleBasedCollator.Compare(current, results[script]) < 0:
                    results[script] = current
    except Exception:

    var result: ICollection<String> = List<String>
      var i: int = 0
      while i < results.Length:
          if results[i] != nil:
result.Add(results[i])
++i
    return result
proc IsUnassignedBoundary(s: string): bool =
    return s[0] == 64977 && UScript.GetScript(Character.CodePointAt(s, 1)) == UScript.Unknown
proc TestZZZ*() =

proc TestSimplified*() =
CheckBuckets("zh", simplifiedNames, UCultureInfo("en"), "W", "西")
proc TestTraditional*() =
CheckBuckets("zh_Hant", traditionalNames, UCultureInfo("en"), "亟", "南門")
proc TestHaniFirst*() =
    var coll: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(UCultureInfo.InvariantCulture))
coll.SetReorderCodes(UScript.Han)
    var index: AlphabeticIndex<object> = AlphabeticIndex<object>(coll)
assertEquals("getBucketCount()", 1, index.BucketCount)
index.AddLabels(CultureInfo("en"))
assertEquals("getBucketCount()", 28, index.BucketCount)
    var bucketIndex: int = index.GetBucketIndex("西")
assertEquals("getBucketIndex(U+897F)", 0, bucketIndex)
    bucketIndex = index.GetBucketIndex("i")
assertEquals("getBucketIndex(i)", 9, bucketIndex)
    bucketIndex = index.GetBucketIndex("α")
assertEquals("getBucketIndex(Greek alpha)", 27, bucketIndex)
    bucketIndex = index.GetBucketIndex(UTF16.ValueOf(327685))
assertEquals("getBucketIndex(U+50005)", 27, bucketIndex)
    bucketIndex = index.GetBucketIndex("￿")
assertEquals("getBucketIndex(U+FFFF)", 27, bucketIndex)
proc TestPinyinFirst*() =
    var coll: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(UCultureInfo("zh")))
coll.SetReorderCodes(UScript.Han)
    var index: AlphabeticIndex<object> = AlphabeticIndex<object>(coll)
assertEquals("getBucketCount()", 28, index.BucketCount)
index.AddLabels(CultureInfo("zh"))
assertEquals("getBucketCount()", 28, index.BucketCount)
    var bucketIndex: int = index.GetBucketIndex("西")
assertEquals("getBucketIndex(U+897F)", 'X' - 'A' + 1, bucketIndex)
    bucketIndex = index.GetBucketIndex("i")
assertEquals("getBucketIndex(i)", 9, bucketIndex)
    bucketIndex = index.GetBucketIndex("α")
assertEquals("getBucketIndex(Greek alpha)", 27, bucketIndex)
    bucketIndex = index.GetBucketIndex(UTF16.ValueOf(327685))
assertEquals("getBucketIndex(U+50005)", 27, bucketIndex)
    bucketIndex = index.GetBucketIndex("￿")
assertEquals("getBucketIndex(U+FFFF)", 27, bucketIndex)
proc TestSchSt*() =
    var index: AlphabeticIndex<object> = AlphabeticIndex<object>(UCultureInfo("de"))
index.AddLabels(UnicodeSet("[Æ{Sch*}{St*}]"))
    var immIndex = index.BuildImmutableIndex
assertEquals("getBucketCount()", 31, index.BucketCount)
assertEquals("immutable getBucketCount()", 31, immIndex.BucketCount)
    var testCases: String[][] = @[@["Adelbert", "1", "A"], @["Afrika", "1", "A"], @["Æsculap", "2", "Æ"], @["Aesthet", "2", "Æ"], @["Berlin", "3", "B"], @["Rilke", "19", "R"], @["Sacher", "20", "S"], @["Seiler", "20", "S"], @["Sultan", "20", "S"], @["Schiller", "21", "Sch"], @["Steiff", "22", "St"], @["Thomas", "23", "T"]]
    var labels: IList<String> = index.GetBucketLabels
    for testCase in testCases:
        var name: String = testCase[0]
        var bucketIndex: int = int.Parse(testCase[1], CultureInfo.InvariantCulture)
        var label: String = testCase[2]
        var msg: String = "getBucketIndex(" + name + ")"
assertEquals(msg, bucketIndex, index.GetBucketIndex(name))
        msg = "immutable " + msg
assertEquals(msg, bucketIndex, immIndex.GetBucketIndex(name))
        msg = "bucket label (" + name + ")"
assertEquals(msg, label, labels[index.GetBucketIndex(name)])
        msg = "immutable " + msg
assertEquals(msg, label, immIndex.GetBucket(bucketIndex).Label)
proc TestNoLabels*() =
    var coll: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(UCultureInfo.InvariantCulture))
    var index: AlphabeticIndex<int> = AlphabeticIndex<int>(coll)
index.AddRecord("西", 0)
index.AddRecord("i", 0)
index.AddRecord("α", 0)
assertEquals("getRecordCount()", 3, index.RecordCount)
assertEquals("getBucketCount()", 1, index.BucketCount)
    var bucket = index.First
assertEquals("underflow label type", BucketLabelType.Underflow, bucket.LabelType)
assertEquals("all records in the underflow bucket", 3, bucket.Count)
proc TestChineseZhuyin*() =
    var index: AlphabeticIndex<object> = AlphabeticIndex<object>(UCultureInfo.GetCultureInfoByIetfLanguageTag("zh-u-co-zhuyin"))
    var immIndex = index.BuildImmutableIndex
assertEquals("getBucketCount()", 38, immIndex.BucketCount)
assertEquals("label 1", "ㄅ", immIndex.GetBucket(1).Label)
assertEquals("label 2", "ㄆ", immIndex.GetBucket(2).Label)
assertEquals("label 3", "ㄇ", immIndex.GetBucket(3).Label)
assertEquals("label 4", "ㄈ", immIndex.GetBucket(4).Label)
assertEquals("label 5", "ㄉ", immIndex.GetBucket(5).Label)
proc TestJapaneseKanji*() =
    var index: AlphabeticIndex<object> = AlphabeticIndex<object>(UCultureInfo("ja"))
    var immIndex: ImmutableIndex<object> = index.BuildImmutableIndex
    var kanji: int[] = @[20124, 38343, 19968, 22769]
    var overflowIndex: int = immIndex.BucketCount - 1
      var i: int = 0
      while i < kanji.Length:
          var msg: String = String.Format("kanji[{0}]=U+{1:x4} in overflow bucket", i, kanji[i])
assertEquals(msg, overflowIndex, immIndex.GetBucketIndex(UTF16.ValueOf(kanji[i])))
++i
proc TestFrozenCollator*() =
    var coll: RuleBasedCollator = cast[RuleBasedCollator](Collator.GetInstance(UCultureInfo("da")))
    coll.Strength = Collator.Identical
coll.Freeze
    var index: AlphabeticIndex<object> = AlphabeticIndex<object>(coll)
assertEquals("same strength as input Collator", Collator.Identical, index.Collator.Strength)
proc TestChineseUnihan*() =
    var index: AlphabeticIndex<object> = AlphabeticIndex<object>(UCultureInfo("zh-u-co-unihan"))
index.SetMaxLabelCount(500)
assertEquals("getMaxLabelCount()", 500, index.MaxLabelCount)
    var immIndex: ImmutableIndex<object> = index.BuildImmutableIndex
    var bucketCount: int = immIndex.BucketCount
    if bucketCount < 216:
Errln("too few buckets/labels for Chinese/unihan: " + bucketCount + " (is zh/unihan data available?)")
        return
    else:
Logln("Chinese/unihan has " + bucketCount + " buckets/labels")
    var bucketIndex: int = index.GetBucketIndex("九")
assertEquals("getBucketIndex(U+4E5D)", 5, bucketIndex)
    bucketIndex = index.GetBucketIndex("甧")
assertEquals("getBucketIndex(U+7527)", 101, bucketIndex)
proc TestAddLabels_Locale*() =
    var ulocaleIndex: AlphabeticIndex<string> = AlphabeticIndex<String>(UCultureInfo("en_CA"))
    var localeIndex: AlphabeticIndex<string> = AlphabeticIndex<String>(CultureInfo("en-CA"))
ulocaleIndex.AddLabels(UCultureInfo("zh_Hans"))
localeIndex.AddLabels(CultureInfo("zh-Hans"))
assertEquals("getBucketLables() results of ulocaleIndex and localeIndex differ", ulocaleIndex.GetBucketLabels, localeIndex.GetBucketLabels)
proc TestGetRecordCount_empty*() =
assertEquals("Record count of empty index not 0", 0, AlphabeticIndex<String>(UCultureInfo("en_CA")).RecordCount)
proc TestGetRecordCount_withRecords*() =
assertEquals("Record count of index with one record not 1", 1, AlphabeticIndex<String>(UCultureInfo("en_CA")).AddRecord("foo", nil).RecordCount)
proc TestFlowLabels*() =
    var index: AlphabeticIndex<string> = AlphabeticIndex<string>(UCultureInfo("en")).AddLabels(UCultureInfo.GetCultureInfoByIetfLanguageTag("ru"))
index.SetUnderflowLabel("underflow")
index.SetOverflowLabel("overflow")
index.SetInflowLabel("inflow")
index.AddRecord("!", nil)
index.AddRecord("α", nil)
index.AddRecord("ꭰ", nil)
    var underflowBucket: Bucket<string> = nil
    var overflowBucket: Bucket<string> = nil
    var inflowBucket: Bucket<string> = nil
    for bucket in index:
        case bucket.LabelType
        of BucketLabelType.Underflow:
assertNull("LabelType not null", underflowBucket)
            underflowBucket = bucket
            break
        of BucketLabelType.Overflow:
assertNull("LabelType not null", overflowBucket)
            overflowBucket = bucket
            break
        of BucketLabelType.Inflow:
assertNull("LabelType not null", inflowBucket)
            inflowBucket = bucket
            break
assertNotNull("No bucket 'underflow'", underflowBucket)
assertEquals("Wrong bucket label", "underflow", underflowBucket.Label)
assertEquals("Wrong bucket label", "underflow", index.UnderflowLabel)
assertEquals("Bucket size not 1", 1, underflowBucket.Count)
assertNotNull("No bucket 'overflow'", overflowBucket)
assertEquals("Wrong bucket label", "overflow", overflowBucket.Label)
assertEquals("Wrong bucket label", "overflow", index.OverflowLabel)
assertEquals("Bucket size not 1", 1, overflowBucket.Count)
assertNotNull("No bucket 'inflow'", inflowBucket)
assertEquals("Wrong bucket label", "inflow", inflowBucket.Label)
assertEquals("Wrong bucket label", "inflow", index.InflowLabel)
assertEquals("Bucket size not 1", 1, inflowBucket.Count)