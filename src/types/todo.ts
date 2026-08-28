export interface Todo {
  id: number;
  title: string;
  completed: boolean;
  userId?: number;
}

export type CreateTodoInput = Pick<Todo, 'title' | 'completed'>;
export type UpdateTodoInput = Partial<Pick<Todo, 'title' | 'completed'>>;
