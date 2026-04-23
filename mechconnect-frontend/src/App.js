import { Routes, Route } from "react-router-dom";
import MechanicsPage from "./pages/MechanicsPage";
import MechanicDetailsPage from "./pages/MechanicDetailsPage";

function App() {

  return (
    <Routes>

      <Route path="/" element={<MechanicsPage />} />

      <Route path="/mechanic/:id" element={<MechanicDetailsPage />} />

    </Routes>
  );

}

export default App;