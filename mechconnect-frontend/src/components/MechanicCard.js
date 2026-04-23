import { Link } from "react-router-dom";

function MechanicCard({ mechanic }) {

  return (
    <div style={{border:"1px solid gray", padding:"10px", margin:"10px"}}>

      <Link to={`/mechanic/${mechanic.id}`}>

        <h3>{mechanic.shopName}</h3>

      </Link>

      <p><b>Mechanic:</b> {mechanic.name}</p>

      <p><b>City:</b> {mechanic.city}</p>

      <p><b>Experience:</b> {mechanic.experience} years</p>

      <p><b>Expertise:</b> {mechanic.expertise}</p>

    </div>
  );

}

export default MechanicCard;