# "Namespace: ICU4N.Dev.Test.Format"
type
  PluralRulesFactory = ref object
    Normal: PluralRulesFactory = PluralRulesFactoryVanilla

proc newPluralRulesFactory(): PluralRulesFactory =

type
  PluralRulesFactoryVanilla = ref object


proc HasOverride*(locale: UCultureInfo): bool =
    return false
proc GetInstance*(localeName: string, ordinal: PluralType): PluralRules =
    return PluralRules.GetInstance(localeName, ordinal)
proc GetInstance*(locale: UCultureInfo, ordinal: PluralType): PluralRules =
    return PluralRules.GetInstance(locale, ordinal)
proc GetUCultures*(): UCultureInfo[] =
    return PluralRules.GetUCultures
proc GetFunctionalEquivalent*(locale: UCultureInfo, isAvailable: bool): UCultureInfo =
    return PluralRules.GetFunctionalEquivalent(locale, isAvailable)
proc GetFunctionalEquivalent*(locale: UCultureInfo): UCultureInfo =
    return PluralRules.GetFunctionalEquivalent(locale)