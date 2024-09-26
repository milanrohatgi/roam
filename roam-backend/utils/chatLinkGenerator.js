// utils/chatLinkGenerator.js

function generateChatLink(carpoolId, participants) {
  // This is a placeholder. In a real app, you'd generate a deep link to an SMS or messaging app
  const participantPhones = participants.map(p => encodeURIComponent(p.phone)).join(',');
  return `sms:${participantPhones}?body=Join%20our%20Roam%20carpool%20chat!%20Carpool%20ID:%20${carpoolId}`;
}

module.exports = generateChatLink;
