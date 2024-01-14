##################################################
# Security Hub Account Member
##################################################
resource "aws_securityhub_member" "this" {
  for_each = var.member_config != null ? { for member in var.member_config : member.account_id => member } : {}

  account_id = each.value.account_id
  email      = each.value.email
  invite     = each.value.invite
}

resource "aws_securityhub_account" "member" {
  for_each = var.member_config != null ? { for member in var.member_config : member.account_id => member } : {}
}

##################################################
# Security Hub Invite
##################################################
resource "aws_securityhub_invite_accepter" "member" {
  for_each = var.member_config != null ? { for member in var.member_config : member.account_id => member if member.invite } : {}

  master_id = aws_securityhub_member.this[each.key].master_id

  depends_on = [aws_securityhub_account.member]
}