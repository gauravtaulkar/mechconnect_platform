import { useEffect, useState } from "react";
import { getMechanics } from "../api/mechanicApi";
import MechanicCard from "../components/MechanicCard";

function MechanicsPage() {

  const [mechanics, setMechanics] = useState([]);

  useEffect(() => {

    getMechanics()
      .then(response => {
        setMechanics(response.data);
      })
      .catch(error => {
        console.error(error);
      });

  }, []);

  return (

    <div>

      <h1>Available Mechanics</h1>

      {mechanics.map(mechanic => (
        <MechanicCard key={mechanic.id} mechanic={mechanic} />
      ))}

    </div>

  );

}

export default MechanicsPage;