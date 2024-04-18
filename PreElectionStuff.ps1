# import the exported list of candidates from Democracy Club
$arrCandidates = Import-Csv .\Downloads\dc-candidates-election_id_localmanchester2024-05-02-2024-04-12T10-02-48.csv

# in Excel, create a mapping of your ward names between Demo Club and Wikipedia
# this is possible in a text editor but use tab as your delimiter since commas are used in Wiki article names
$arrCandidates.post_label | select -Unique | sort
$arrWards = Import-Excel .\OneDrive\LDs\DemoClubToWardNames.xlsx -Sheet Manchester
# $arrWards = Import-Csv .\path\MyAuthorityWards.csv -Delimeter `t

# in Excel or a text editor create a map of Demo Club's political parties to Wikipedia's
# minor parties use a different Election Box template
$arrParties = Import-Excel .\OneDrive\LDs\DemoClubToWardNames.xlsx -Sheet Parties
$hashParties = @{}
ForEach ($objParty in $arrParties) { $hashParties.Add($objParty.demoClubPartyID, $objParty.wikiPartyPrefix) }

# there's a bunch of repeated stuff that sits on the end of election boxes
$strAppendyBits = "<!--`n{{Election box majority|votes= |percentage= |change=}}`n{{Election box rejected||votes= |percentage= |change= }}`n{{Election box turnout||votes= |percentage= |change= }}`n{{Election box registered electors||reg. electors= }}`n-->`n{{Election box end}}`n`n"

# and now we're good to go
$objWikiText = New-Object -TypeName System.Text.StringBuilder
[void]$objWikiText.Append("== Candidates ==`n`n`n")
ForEach ($objWard in $arrWards) {
  [void]$objWikiText.Append("=== $($objWard.wardWiki) ===`n`n<noinclude>{{Election box begin | title=$($objWard.wardElectionBoxTitle)}}</noinclude>`n")
  ForEach ($objCandidate in ($arrCandidates | ?{$_.post_label -eq $objWard.wardDemoClub})) {
    [void]$objWikiText.Append("$($hashParties[$objCandidate.party_id])|candidate=$($objCandidate.person_name)|votes= |percentage= |change= }}`n")
  }
  [void]$objWikiText.Append($strAppendyBits)
}

# yeet this in to the clipboard and paste it in to wikipedia
$objWikiText.ToString() | Set-Clipboard
