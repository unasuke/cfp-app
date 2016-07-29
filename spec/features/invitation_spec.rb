require 'rails_helper'

feature 'Speaker Invitations' do
  let(:second_speaker_email) { 'second_speaker@example.com' }
  let(:user) { create(:user) }
  let(:event) { create(:event, state: 'open') }
  let(:proposal) { create(:proposal,
                          title: 'Hello there',
                          abstract: 'Well then.',
                          event: event)
  }
  let!(:speaker) { create(:speaker,
                         user: user,
                         event: event,
                         proposal: proposal)
  }

  let(:go_to_proposal) {
    login_as(user)
    visit(event_proposal_path(event_slug: proposal.event.slug, uuid: proposal))
  }

  context "Creating an invitation" do
    before :each do
      go_to_proposal
      click_on "Invite a Speaker"
      fill_in "Email", with: second_speaker_email
    end

    scenario "A speaker can invite another speaker" do
      click_button "Invite"
      expect(page).
        to(have_text(second_speaker_email))
    end

    it "emails the pending speaker" do
      ActionMailer::Base.deliveries.clear
      click_button "Invite"
      expect(ActionMailer::Base.deliveries.first.to).to include(second_speaker_email)
    end

    scenario "A speaker can re-invite the same speaker" do
      click_button "Invite"
      fill_in "Email", with: second_speaker_email
      click_button "Invite"
      expect(page).
        to(have_text(second_speaker_email))
    end
  end

  context "Removing an invitation" do
    let!(:invitation) { create(:invitation, proposal: proposal, email: second_speaker_email) }

    scenario "A speaker can remove an invitation" do
      go_to_proposal
      click_link "Remove"
      expect(proposal.reload.invitations).not_to include(invitation)
    end
  end

  context "Resending an invitation" do
    let!(:invitation) { create(:invitation, proposal: proposal, email: second_speaker_email) }
    after { ActionMailer::Base.deliveries.clear }

    scenario "A speaker can resend an invitation" do
      go_to_proposal
      click_link "Resend"
      expect(ActionMailer::Base.deliveries.last.to).to include(second_speaker_email)
    end
  end

  context "Responding to an invitation" do
    let(:second_speaker) { create(:user, email: second_speaker_email) }
    let!(:invitation) { create(:invitation,
                               proposal: proposal,
                               email: second_speaker_email,
                               user: second_speaker)
    }
    let(:other_proposal) { create(:proposal, event: event) }
    let!(:other_invitation) { create(:invitation,
                                     proposal: other_proposal,
                                     email: second_speaker_email)
    }

    before :each do
      login_as(second_speaker)
      visit invitation_url(invitation, invitation_slug: invitation.slug)
    end

    it "shows the proposal" do
      expect(page).to have_text(proposal.title)
    end

    it "shows the invitation on the user's dashboard" do
      pending "This fails because it can't find div.invitations for some reason"

      visit proposals_path
      within(:css, 'div.invitations') do
        expect(page).to have_text(other_proposal.title)
      end
    end

    context "When accepting" do
      before { click_link "Accept" }

      it "marks the invitation as accepted" do
        expect(invitation.reload.state).to eq(Invitation::State::ACCEPTED)
      end
    end

    context "When declining" do
      before { click_link "Decline" }

      it "redirects the user back to the proposal page" do
        expect(page).to have_text("You have declined this invitation")
      end

      it "marks the invitation as declined" do
        expect(invitation.reload.state).to eq(Invitation::State::DECLINED)
      end
    end

    it "User can view proposal before accepting invite" do
      pending "This fails because it can't find div.invitations for some reason"

      visit proposals_path

      within(:css, 'div.invitations') do
        expect(page).to have_text(other_proposal.title)
        expect(page).to have_link("Accept")
        expect(page).to have_link("Decline")
      end

      click_link(other_proposal.title)

      expect(current_path).to eq(event_proposal_path(event_slug: other_proposal.event.slug, uuid: other_proposal))
    end
  end
end
