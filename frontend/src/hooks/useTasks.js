import { useState, useEffect } from 'react';
import { fetchTasks } from '../api';

export function useTasks(query, status, page, pageSize) {
  const [tasks, setTasks] = useState([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    // FIX: AbortController cancels the previous request when inputs change,
    // so a slow old response can never overwrite a newer one (race condition).
    const controller = new AbortController();
    setLoading(true);
    setError(null); // FIX: clear old error on every new request

    fetchTasks({ query, status, page, pageSize, signal: controller.signal })
      .then((data) => {
        setTasks(data.items);
        setTotal(data.total);
        setLoading(false);
      })
      .catch((err) => {
        if (err.name === 'AbortError') return; // superseded by a newer request
        setError(err.message);
        setLoading(false); // FIX: loading was never reset on error
      });

    return () => controller.abort();
  }, [query, status, page, pageSize]);

  return { tasks, total, loading, error };
}
