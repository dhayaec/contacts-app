import type { CreateTodoInput, Todo, UpdateTodoInput } from '@/types/todo';

const BASE_URL = 'https://jsonplaceholder.typicode.com';

class TodoError extends Error {
  status: number;
  constructor(message: string, status: number) {
    super(message);
    this.name = 'TodoError';
    this.status = status;
  }
}

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(`${BASE_URL}${path}`, {
    headers: { 'Content-Type': 'application/json' },
    ...init,
  });
  if (!res.ok) {
    throw new TodoError(`Request failed: ${res.statusText}`, res.status);
  }
  return (await res.json()) as T;
}

export const todoApi = {
  list: () => request<Todo[]>('/todos?_limit=20'),
  get: (id: number) => request<Todo>(`/todos/${id}`),
  create: (input: CreateTodoInput) =>
    request<Todo>('/todos', {
      method: 'POST',
      body: JSON.stringify(input),
    }),
  update: (id: number, input: UpdateTodoInput) =>
    request<Todo>(`/todos/${id}`, {
      method: 'PATCH',
      body: JSON.stringify(input),
    }),
  remove: (id: number) =>
    request<Todo>(`/todos/${id}`, { method: 'DELETE' }),
};
