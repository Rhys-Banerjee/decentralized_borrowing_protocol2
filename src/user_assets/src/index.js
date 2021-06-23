import { Actor, HttpAgent } from '@dfinity/agent';
import { idlFactory as user_idl, canisterId as user_id } from 'dfx-generated/user';

const agent = new HttpAgent();
const user = Actor.createActor(user_idl, { agent, canisterId: user_id });

document.getElementById("accntBtn").addEventListener("click", async () => {
  const name = document.getElementById("accntInput").value.toString();
  const opening = await user.test_run(name);
  const creation = await user.create_Account(name);
  document.getElementById("accntResult").innerText = opening;
});
document.getElementById("TroveBtn").addEventListener("click", async () => {
  const alert = await user.create_Trove();
  document.getElementById("Trove-Result").innerText = alert;
});

document.getElementById("ICPDepBtn").addEventListener("click", async () => {
  const amount = document.getElementById("ICPInput").value.toString();
  const depositICP = await user.deposit_ICP(amount);
  document.getElementById("ICPResults").innerText = opening;
});

document.getElementById("SDRDepBtn").addEventListener("click", async () => {
  const amount = document.getElementById("SDRInput").value.toString();
  const depositICP = await user.deposit_SDR(amount);
  document.getElementById("SDRResults").innerText = opening;
});

document.getElementById("ICPWithBtn").addEventListener("click", async () => {
  const amount = document.getElementById("ICPWithInput").value.toString();
  const depositICP = await user.withdraw_ICP(amount);
  document.getElementById("ICPWithResults").innerText = opening;
});

document.getElementById("SDRWithBtn").addEventListener("click", async () => {
  const amount = document.getElementById("SDRWithInput").value.toString();
  const depositICP = await user.withdraw_SDR(amount);
  document.getElementById("SDRWithResults").innerText = opening;
});

document.getElementById("CloseTroveBtn").addEventListener("click", async () => {
  const alert = await user.close_Trove();
  document.getElementById("CloseTroveResult").innerText = alert;
});