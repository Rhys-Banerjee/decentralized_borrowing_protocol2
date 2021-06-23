import { Actor, HttpAgent } from '@dfinity/agent';
import { idlFactory as user_idl, canisterId as user_id } from 'dfx-generated/user';

const agent = new HttpAgent();
const user = Actor.createActor(user_idl, { agent, canisterId: user_id });

document.getElementById("clickMeBtn").addEventListener("click", async () => {
  const name = document.getElementById("name").value.toString();
  const greeting = await user.greet(name);

  document.getElementById("greeting").innerText = greeting;
});
