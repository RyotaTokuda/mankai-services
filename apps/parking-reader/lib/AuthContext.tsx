import React, { createContext, useContext, useState, useCallback, type ReactNode } from "react";

interface UserMetadata {
  full_name?: string;
  avatar_url?: string;
  name?: string;
  [key: string]: unknown;
}

export interface User {
  id: string;
  email?: string;
  user_metadata?: UserMetadata;
}

interface AuthContextValue {
  user: User | null;
  loading: boolean;
  signInWithGoogle: () => Promise<void>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue>({
  user: null,
  loading: false,
  signInWithGoogle: async () => {},
  signOut: async () => {},
});

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user] = useState<User | null>(null);
  const [loading] = useState(false);

  const signInWithGoogle = useCallback(async () => {
    // TODO: implement Google sign-in
  }, []);

  const signOut = useCallback(async () => {
    // TODO: implement sign-out
  }, []);

  return (
    <AuthContext.Provider value={{ user, loading, signInWithGoogle, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}
