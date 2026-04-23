import axios from "axios";

const API_URL = "http://localhost:8080/api/mechanics";

export const getMechanics = () => {
  return axios.get(API_URL);
};