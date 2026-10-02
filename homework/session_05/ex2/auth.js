// Module authentication
function login(username, password) {
  if (!username || !password) {
    return { ok: false, message: "Invalid credentials" };
  }
  return { ok: true, message: "Login success" };
}

function validateEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function hashPassword(password) {
  // Gia lap: dao nguoc chuoi, chi dung de demo
  return "hashed_" + password.split("").reverse().join("");
}

module.exports = { login, validateEmail, hashPassword };
