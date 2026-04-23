import { useParams } from "react-router-dom";

function MechanicDetailsPage() {

  const { id } = useParams();

  return (

    <div>

      <h1>Mechanic Details</h1>

      <p>Mechanic ID: {id}</p>

    </div>

  );

}

export default MechanicDetailsPage;