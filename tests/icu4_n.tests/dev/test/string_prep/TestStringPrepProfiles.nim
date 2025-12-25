# "Namespace: ICU4N.Dev.Test.StringPrep"
type
  TestStringPrepProfiles = ref object
    testCases: seq[string] = @[@["RFC4013_SASLPREP", "user: ૆ ­password1", "user: ૆ password1"], @["RFC4011_MIB", "Policy͏‍Base d᠆‌", "PolicyBase d"], @["RFC4505_TRACE", "Anony  mous　஝͏­", "Anony  mous　஝͏­"], @["RFC4518_LDAP", "Ldapﬁ­Test  ⁢ing", "LdapfiTest  ing"], @["RFC4518_LDAP_CI", "Ldapﬁ­Test  ⁢ing12345", "ldapfitest  ing12345"], @["RFC3920_RESOURCEPREP", "ServerXM⁠︀︉PP s p ", "ServerXMPP s p "], @["RFC3920_NODEPREP", "Server‍XMPPGreEKϐ", "serverxmppgreekβ"], @["RFC3722_ISCSI", "InternetSmallComputerﬁ2⁵Interface", "internetsmallcomputerfi25interface", "FAILThisShouldFailBecauseOfThis/", "FAIL"], @["RFC3530_NFS4_CS_PREP", "­User⁠Name@ ۝DOMAIN.com", "UserName@ ۝DOMAIN.com"], @["RFC3530_NFS4_CS_PREP_CI", "­User⁠Name@ ۝DOMAIN.com", "username@ ۝domain.com"], @["RFC3530_NFS4_CIS_PREP", "AA‌‍ @@DomAin.org", "aa @@domain.org"], @["RFC3530_NFS4_MIXED_PREP_PREFIX", "PrefixUser ﬁEnd", "PrefixUser fiEnd"], @["RFC3530_NFS4_MIXED_PREP_SUFFIX", "SuffixDomain ﬁEnD", "suffixdomain fiend"]]

proc GetOptionFromProfileName(profileName: String): StringPrepProfile =
    if profileName.Equals("RFC4013_SASLPREP"):
        return StringPrepProfile.Rfc4013SaslPrep

    elif profileName.Equals("RFC4011_MIB"):
        return StringPrepProfile.Rfc4011MIB
    else:
      if profileName.Equals("RFC4505_TRACE"):
          return StringPrepProfile.Rfc4505Trace

      elif profileName.Equals("RFC4518_LDAP"):
          return StringPrepProfile.Rfc4518Ldap
      else:
        if profileName.Equals("RFC4518_LDAP_CI"):
            return StringPrepProfile.Rfc4518LdapCaseInsensitive

        elif profileName.Equals("RFC3920_RESOURCEPREP"):
            return StringPrepProfile.Rfc3920ResourcePrep
        else:
          if profileName.Equals("RFC3920_NODEPREP"):
              return StringPrepProfile.Rfc3920NodePrep

          elif profileName.Equals("RFC3722_ISCSI"):
              return StringPrepProfile.Rfc3722iSCSI
          else:
            if profileName.Equals("RFC3530_NFS4_CS_PREP"):
                return StringPrepProfile.Rfc3530Nfs4CsPrep

            elif profileName.Equals("RFC3530_NFS4_CS_PREP_CI"):
                return StringPrepProfile.Rfc3530Nfs4CsPrepCaseInsensitive
            else:
              if profileName.Equals("RFC3530_NFS4_CIS_PREP"):
                  return StringPrepProfile.Rfc3530Nfs4CisPrep

              elif profileName.Equals("RFC3530_NFS4_MIXED_PREP_PREFIX"):
                  return StringPrepProfile.Rfc3530Nfs4MixedPrepPrefix
              else:
                if profileName.Equals("RFC3530_NFS4_MIXED_PREP_SUFFIX"):
                    return StringPrepProfile.Rfc3530Nfs4MixedPrepSuffix
    return cast[StringPrepProfile](-1)
proc TestProfiles*() =
    var profileName: String = nil
    var sprep: StringPrep = nil
    var result: String = nil
    var src: String = nil
    var expected: String = nil
      var i: int = 0
      while i < testCases.Length:
            var j: int = 0
            while j < testCases[i].Length:
                if j == 0:
                    profileName = testCases[i][j]
                    sprep = StringPrep.GetInstance(GetOptionFromProfileName(profileName))
                else:
                    src = testCases[i][j]
                    expected = testCases[i][++j]
                    try:
                        result = sprep.Prepare(src, StringPrepOptions.AllowUnassigned)
                        if src.StartsWith("FAIL", StringComparison.Ordinal):
Errln("Failed: Expected error for Test[" + i + "] Profile: " + profileName)

                        elif !result.Equals(expected):
Errln("Failed: Test[" + i + "] Result string does not match expected string for StringPrep test for profile: " + profileName)
                    except StringPrepFormatException:
                        if !src.StartsWith("FAIL", StringComparison.Ordinal):
Errln("Failed: Test[" + i + "] StringPrep profile " + profileName + " got error: " + ex)
++j
++i